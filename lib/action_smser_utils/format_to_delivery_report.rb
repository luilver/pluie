module ActionSmserUtils
      module FormatToDeliveryReport
        def to_csv(options={},reports)
          CSV.generate(options) do |csv|
            csv << [I18n.translate('id'), I18n.translate('created_at'),I18n.translate('msg_id'),I18n.translate('route').capitalize,I18n.translate('message').capitalize,  I18n.translate('status'),I18n.translate('status_updated_at'),I18n.translate('recipient'),I18n.translate('sms_type')]
            reports.each do |dr|
              csv << [dr.id, I18n.localize(dr.created_at, :format => :date_time).html_safe,dr.msg_id,dr.gateway,dr.body, ActionSmserUtils.show_dlr_status(dr.status),I18n.localize(dr.status_updated_at, :format => :date_time).html_safe,dr.to,I18n.translate("activerecord.models.#{dr.sms_type.tableize.singularize+'_xls'}")]
            end
          end
        end
      end
end

ActionSmser::DeliveryReport.extend  ActionSmserUtils::FormatToDeliveryReport

