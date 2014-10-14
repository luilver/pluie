module SmsHelper
  def self.sms_type(type)
    case type
    when ActionSmserUtils::PLUIE_MSG
      type
    else
      I18n.translate("activerecord.models.#{type.tableize.singularize}").html_safe
    end
  end
end