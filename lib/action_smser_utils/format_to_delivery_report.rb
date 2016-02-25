module ActionSmserUtils
      module FormatToDeliveryReport
        def to_csv(options={},reports)
          CSV.generate(options) do |csv|
            csv << [I18n.translate('id'), I18n.translate('created_at'),I18n.translate('msg_id'),I18n.translate('route'),I18n.translate('status'),I18n.translate('status_updated_at'),I18n.translate('to'),I18n.translate('sms_type')]
            reports.each do |dr|
              csv << [dr.id,dr.created_at,dr.msg_id,dr.gateway,dr.status,dr.status_updated_at,dr.to,dr.sms_type]
            end
          end
        end
      end
end

ActionSmser::DeliveryReport.extend  ActionSmserUtils::FormatToDeliveryReport

