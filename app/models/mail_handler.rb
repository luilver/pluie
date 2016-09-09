class MailHandler < ActionMailer::Base
  include ActionView::Helpers::SanitizeHelper

  class UnauthorizedAction < StandardError; end
  class MissingInformation < StandardError; end

  attr_reader :email, :user

  def self.receive(email, options={})
    @@handler_options = options.dup

    @@handler_options[:single_message] ||= {}

    if @@handler_options[:allow_override].is_a?(String)
      @@handler_options[:allow_override] = @@handler_options[:allow_override].split(',').collect(&:strip)
    end
    @@handler_options[:allow_override] ||= []

    @@handler_options[:no_account_notice] = (@@handler_options[:no_account_notice].to_s == '1')
    @@handler_options[:no_notification] = (@@handler_options[:no_notification].to_s == '1')
    @@handler_options[:no_permission_check] = (@@handler_options[:no_permission_check].to_s == '1')

    email.force_encoding('ASCII-8BIT') if email.respond_to?(:force_encoding)
    super(email)
  end

  # Extracts MailHandler options from environment variables
  # Use when receiving emails with rake tasks
  def self.extract_options_from_env(env)
    options = {:single_message => {}}
    %w(user).each do |option|
      options[:single_message][option.to_sym] = env[option] if env[option]
    end
    options
  end

  def logger
    Rails.logger
  end

  cattr_accessor :ignored_emails_headers
  @@ignored_emails_headers = {
    'X-Auto-Response-Suppress' => 'oof',
    'Auto-Submitted' => /^auto-/
  }

  # Processes incoming emails
  # Returns the created object (eg. a single_message, a message) or false
  def receive(email)
    @email = email
    sender_email = email.from.to_a.first.to_s.strip
    # Ignore emails received from the application emission address to avoid hell cycles
    if sender_email.downcase == 'sms@knal.es'
      if logger
        logger.info  "MailHandler: ignoring email from Knales emission address [#{sender_email}]"
      end
      return false
    end
    # Ignore auto generated emails
    self.class.ignored_emails_headers.each do |key, ignored_value|
      value = email.header[key]
      if value
        value = value.to_s.downcase
        if (ignored_value.is_a?(Regexp) && value.match(ignored_value)) || value == ignored_value
          if logger
            logger.info "MailHandler: ignoring email with #{key}:#{value} header"
          end
          return false
        end
      end
    end
    @user = User.find_by_email(sender_email) if sender_email.present?
    # TODO: set the active flag to user
    # if @user && !@user.active?
    #   if logger
    #     logger.info  "MailHandler: ignoring email from non-active user [#{@user.login}]"
    #   end
    #   return false
    # end
    if @user.nil?
      # Email was submitted by an unknown user
      case @@handler_options[:unknown_user]
      when 'accept'
        @user = User.anonymous
      when 'create'
        @user = create_user_from_email
        if @user
          if logger
            logger.info "MailHandler: [#{@user.login}] account created"
          end
          add_user_to_group(@@handler_options[:default_group])
          unless @@handler_options[:no_account_notice]
            Mailer.account_information(@user, @user.password).deliver
          end
        else
          if logger
            logger.error "MailHandler: could not create account for [#{sender_email}]"
          end
          return false
        end
      else
        # Default behaviour, emails from unknown users are ignored
        if logger
          logger.info  "MailHandler: ignoring email from unknown user [#{sender_email}]"
        end
        return false
      end
    else #User already exists
      single_message_attributes_from_keywords
      if Devise.secure_compare(@user.api_key, @attrs[:api_key])
        User.current = @user
        return dispatch
      else
        if logger
          logger.info  "MailHandler: invalid api_key [#{@attrs[:api_key]}]"
        end
      end
    end
    false
  end

  private

  MESSAGE_ID_RE = %r{^<?sms\.([a-z0-9_]+)\-(\d+)\.\d+(\.[a-f0-9]+)?@}

  def dispatch
    headers = [email.in_reply_to, email.references].flatten.compact
    subject = email.subject.to_s
    if headers.detect {|h| h.to_s =~ MESSAGE_ID_RE}
      klass, object_id = $1, $2.to_i
      method_name = "receive_#{klass}_reply"
      send method_name, object_id if self.class.private_instance_methods.collect(&:to_s).include?(method_name)
    else
      dispatch_to_default
    end
  rescue ActiveRecord::RecordInvalid => e
    # TODO: send a email to the user
    logger.error e.message if logger
    false
  rescue MissingInformation => e
    logger.error "MailHandler: missing information from #{user}: #{e.message}" if logger
    false
  rescue UnauthorizedAction => e
    logger.error "MailHandler: unauthorized attempt from #{user}" if logger
    false
  end

  def dispatch_to_default
    send_single_message
  end

  # Sends a new single_message
  def send_single_message
    single_message = SingleMessage.new(user: user)
    single_message.number = @attrs[:number]
    single_message.message = @attrs[:message]
    single_message.route = user.routes.first

    if single_message.save
      ApplicationHelper::ManageSM.new.send_message_simple(single_message)
      logger.info "MailHandler: single_message ##{single_message.id} sent by #{user}" if logger
    end
    single_message
  end

  def get_keyword(attr, options={})
    @keywords ||= {}
    if @keywords.has_key?(attr)
      @keywords[attr]
    else
      extract_keyword!(plain_text_body, attr, options[:format])
    end
  end

  # Destructively extracts the value for +attr+ in +text+
  # Returns nil if no matching keyword found
  def extract_keyword!(text, attr, format=nil)
    keys = [attr.to_s.humanize]
    keys.reject! {|k| k.blank?}
    keys.collect! {|k| Regexp.escape(k)}
    format ||= '.+'
    keyword = nil
    regexp = /^(#{keys.join('|')})[ \t]*:[ \t]*(#{format})\s*$/i
    if m = text.match(regexp)
      keyword = m[2].strip
      text.gsub!(regexp, '')
    end
    keyword
  end

  # Returns a Hash of single_message attributes extracted from keywords in the email body
  def single_message_attributes_from_keywords()
    return @attrs unless @attrs.nil?
    @attrs = {
      :number => get_keyword(:to),
      :message => get_keyword(:message),
      :api_key => get_keyword(:password),
    }.delete_if {|k, v| v.blank? }
  end

  # Returns a Hash of single_message custom field values extracted from keywords in the email body
  def custom_field_values_from_keywords(customized)
    customized.custom_field_values.inject({}) do |h, v|
      if keyword = get_keyword(v.custom_field.name, :override => true)
        h[v.custom_field.id.to_s] = v.custom_field.value_from_keyword(keyword, customized)
      end
      h
    end
  end

  # Returns the text/plain part of the email
  # If not found (eg. HTML-only email), returns the body with tags removed
  def plain_text_body
    return @plain_text_body unless @plain_text_body.nil?

    parts = if (text_parts = email.all_parts.select {|p| p.mime_type == 'text/plain'}).present?
              text_parts
            elsif (html_parts = email.all_parts.select {|p| p.mime_type == 'text/html'}).present?
              html_parts
            else
              [email]
            end

    parts.reject! do |part|
      part.header[:content_disposition].try(:disposition_type) == 'attachment'
    end

    @plain_text_body = parts.map {|p| to_utf8(p.body.decoded, p.charset)}.join("\r\n")

    # strip html tags and remove doctype directive
    if parts.any? {|p| p.mime_type == 'text/html'}
      @plain_text_body = strip_tags(@plain_text_body.strip)
      @plain_text_body.sub! %r{^<!DOCTYPE .*$}, ''
    end

    @plain_text_body
  end

  def cleaned_up_text_body
    cleanup_body(plain_text_body)
  end

  def cleaned_up_subject
    subject = email.subject.to_s
    subject.strip[0,255]
  end

  def self.full_sanitizer
    @full_sanitizer ||= HTML::FullSanitizer.new
  end

  def self.assign_string_attribute_with_limit(object, attribute, value, limit=nil)
    limit ||= object.class.columns_hash[attribute.to_s].limit || 255
    value = value.to_s.slice(0, limit)
    object.send("#{attribute}=", value)
  end

  # Returns a User from an email address and a full name
  def self.new_user_from_attributes(email_address, fullname=nil)
    user = User.new

    # Truncating the email address would result in an invalid format
    assign_string_attribute_with_limit(user, 'email', email_address)

    names = fullname.blank? ? email_address.gsub(/@.*$/, '').split('.') : fullname.split

    unless user.valid?
      user.email = "user#{Pluie::Utils.random_hex(6)}" unless user.errors[:login].blank?
      user.firstname = "-" unless user.errors[:firstname].blank?
      (puts user.errors[:lastname];user.lastname  = "-") unless user.errors[:lastname].blank?
    end

    user
  end

  # Creates a User for the +email+ sender
  # Returns the user or nil if it could not be created
  def create_user_from_email
    from = email.header['from'].to_s
    addr, name = from, nil
    if m = from.match(/^"?(.+?)"?\s+<(.+@.+)>$/)
      addr, name = m[2], m[1]
    end
    if addr.present?
      user = self.class.new_user_from_attributes(addr, name)
      if @@handler_options[:no_notification]
        user.mail_notification = 'none'
      end
      if user.save
        user
      else
        logger.error "MailHandler: failed to create User: #{user.errors.full_messages}" if logger
        nil
      end
    else
      logger.error "MailHandler: failed to create User: no FROM address found" if logger
      nil
    end
  end

  # Adds the newly created user to default group
  def add_user_to_group(default_group)
    if default_group.present?
      default_group.split(',').each do |group_name|
        if group = Group.named(group_name).first
          group.users << @user
        elsif logger
          logger.warn "MailHandler: could not add user to [#{group_name}], group not found"
        end
      end
    end
  end

  # Removes the email body of text after the truncation configurations.
  def cleanup_body(body)
    delimiters = Setting.mail_handler_body_delimiters.to_s.split(/[\r\n]+/).reject(&:blank?).map {|s| Regexp.escape(s)}
    unless delimiters.empty?
      regex = Regexp.new("^[> ]*(#{ delimiters.join('|') })\s*[\r\n].*", Regexp::MULTILINE)
      body = body.gsub(regex, '')
    end
    body.strip
  end

  def find_assignee_from_keyword(keyword, single_message)
    keyword = keyword.to_s.downcase
    assignable = single_message.assignable_users
    assignee = nil
    assignee ||= assignable.detect {|a|
                   a.mail.to_s.downcase == keyword ||
                     a.login.to_s.downcase == keyword
                 }
    if assignee.nil? && keyword.match(/ /)
      firstname, lastname = *(keyword.split) # "First Last Throwaway"
      assignee ||= assignable.detect {|a|
                     a.is_a?(User) && a.firstname.to_s.downcase == firstname &&
                       a.lastname.to_s.downcase == lastname
                   }
    end
    if assignee.nil?
      assignee ||= assignable.detect {|a| a.name.downcase == keyword}
    end
    assignee
  end

  def to_utf8(str, encoding)
    return str if str.nil?
    str.force_encoding("ASCII-8BIT") if str.respond_to?(:force_encoding)
    if str.empty?
      str.force_encoding("UTF-8") if str.respond_to?(:force_encoding)
      return str
    end
    enc = encoding.blank? ? "UTF-8" : encoding
    if str.respond_to?(:force_encoding)
      if enc.upcase != "UTF-8"
        str.force_encoding(enc)
        str = str.encode("UTF-8", :invalid => :replace,
              :undef => :replace, :replace => '?')
      else
        str.force_encoding("UTF-8")
        if ! str.valid_encoding?
          str = str.encode("US-ASCII", :invalid => :replace,
                :undef => :replace, :replace => '?').encode("UTF-8")
        end
      end
    elsif RUBY_PLATFORM == 'java'
      begin
        ic = Iconv.new('UTF-8', enc)
        str = ic.iconv(str)
      rescue
        str = str.gsub(%r{[^\r\n\t\x20-\x7e]}, '?')
      end
    else
      ic = Iconv.new('UTF-8', enc)
      txtar = ""
      begin
        txtar += ic.iconv(str)
      rescue Iconv::IllegalSequence
        txtar += $!.success
        str = '?' + $!.failed[1,$!.failed.length]
        retry
      rescue
        txtar += $!.success
      end
      str = txtar
    end
    str
  end
end
