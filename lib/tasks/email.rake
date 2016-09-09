namespace :pluie do
  namespace :email do

    desc <<-END_DESC
Read an email from standard input.

General options:
  unknown_user=ACTION      how to handle emails from an unknown user
                           ACTION can be one of the following values:
                           ignore: email is ignored (default)
                           accept: accept as anonymous user
                           create: create a user account
  no_account_notice=1      disable new user account notification

Examples:
  # Default use case
  rake pluie:email:read RAILS_ENV="production" < raw_email

END_DESC

    task :read => :environment do
      MailHandler.receive(STDIN.read, MailHandler.extract_options_from_env(ENV))
    end

    desc <<-END_DESC
Read emails from an IMAP server.

General options:
  unknown_user=ACTION      how to handle emails from an unknown user
                           ACTION can be one of the following values:
                           ignore: email is ignored (default)
                           accept: accept as anonymous user
                           create: create a user account
  no_account_notice=1      disable new user account notification

Available IMAP options:
  host=HOST                IMAP server host (default: 127.0.0.1)
  port=PORT                IMAP server port (default: 143)
  ssl=SSL                  Use SSL? (default: false)
  username=USERNAME        IMAP account
  password=PASSWORD        IMAP password
  folder=FOLDER            IMAP folder to read (default: INBOX)

Processed emails control options:
  move_on_success=MAILBOX  move emails that were successfully received
                           to MAILBOX instead of deleting them
  move_on_failure=MAILBOX  move emails that were ignored to MAILBOX

Examples:
  # Default use case
  rake pluie:email:receive_imap RAILS_ENV="production" \\
    host=imap.foo.bar username=pluie@example.net password=xxx

END_DESC

    task :receive_imap => :environment do
      imap_options = {:host => ENV['host'],
                      :port => ENV['port'],
                      :ssl => ENV['ssl'],
                      :username => ENV['username'],
                      :password => ENV['password'],
                      :folder => ENV['folder'],
                      :move_on_success => ENV['move_on_success'],
                      :move_on_failure => ENV['move_on_failure']}

      Pluie::IMAP.check(imap_options, MailHandler.extract_options_from_env(ENV))
    end

    desc <<-END_DESC
Read emails from an POP3 server.

Available POP3 options:
  host=HOST                POP3 server host (default: 127.0.0.1)
  port=PORT                POP3 server port (default: 110)
  username=USERNAME        POP3 account
  password=PASSWORD        POP3 password
  apop=1                   use APOP authentication (default: false)
  delete_unprocessed=1     delete messages that could not be processed
                           successfully from the server (default
                           behaviour is to leave them on the server)

See pluie:email:receive_imap for more options and examples.
END_DESC

    task :receive_pop3 => :environment do
      pop_options  = {:host => ENV['host'],
                      :port => ENV['port'],
                      :apop => ENV['apop'],
                      :username => ENV['username'],
                      :password => ENV['password'],
                      :delete_unprocessed => ENV['delete_unprocessed']}

      Pluie::POP3.check(pop_options, MailHandler.extract_options_from_env(ENV))
    end

    desc "Send a test email to the user with the provided login name"
    task :test, [:login] => :environment do |task, args|
      include Pluie::I18n
      abort l(:notice_email_error, "Please include the user login to test with. Example: rake pluie:email:test[login]") if args[:login].blank?

      user = User.find_by_login(args[:login])
      abort l(:notice_email_error, "User #{args[:login]} not found") unless user && user.logged?

      ActionMailer::Base.raise_delivery_errors = true
      begin
        Mailer.with_synched_deliveries do
          Mailer.test_email(user).deliver
        end
        puts l(:notice_email_sent, user.mail)
      rescue Exception => e
        abort l(:notice_email_error, e.message)
      end
    end
  end
end
