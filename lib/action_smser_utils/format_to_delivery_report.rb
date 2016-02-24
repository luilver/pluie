# module ActionSmserUtils
#       module FormatToDeliveryReport
#         def to_csv(options={},reports)
#           CSV.generate(options) do |csv|
#             csv << [:to,:status]
#             reports.each do |dr|
#               csv << [dr.to,dr.status]
#             end
#           end
#         end
#       end
# end
#
# ActionSmser::DeliveryReport.extend  ActionSmserUtils::FormatToDeliveryReport

# t.string :msg_id
# t.string :status
# t.datetime :status_updated_at
# t.string :sms_type
# t.text   :log
#
# t.string :to
# t.string :from
# t.string :body
#
# t.string :gateway
# t.integer :re_delivery_of_delivery_report_id
# t.boolean :re_delivered
