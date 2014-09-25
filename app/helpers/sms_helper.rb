module SmsHelper
  def self.sms_type(type)
    I18n.translate("activerecord.models.#{type.tableize.singularize}").html_safe
  end
end
