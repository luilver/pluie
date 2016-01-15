module ActionSmser
  class DeliveryReportsController < Pluie::ApplicationController
    before_filter :admin_access_only, :except => :gateway_commit
    before_action :set_delivery_report, only: [:show]
    protect_from_forgery :except => :gateway_commit
    skip_before_filter :authenticate_user!, only: [:gateway_commit]
    helper_method :items_within_page
    helper_method :selected_user

    def gateway_commit

      updated_count = 0


      if !ActionSmser.delivery_options[:gateway_commit].blank? &&
          !ActionSmser.delivery_options[:gateway_commit][params['gateway']].blank?

        ActionSmser::Logger.info("Gateway_commit found parser for gateway: #{params['gateway']}")

        dr_var_array = ActionSmser.delivery_options[:gateway_commit][params['gateway']].send(:process_delivery_report, params)
        dr_array = []

        if !dr_var_array.blank?
          dr_var_array.each do |dr_update|
            msg_id = dr_update["msg_id"]

            if ActionSmser::DeliveryReport.where(:msg_id=>msg_id).blank?
                dr=ActionSmser::DeliveryReport.new
                dr.gateway=params['gateway']
                dr_update.each_pair do |key, value|
                  dr.send("#{key}=", value) if dr.attribute_names.include?(key.to_s)
                end
                dr.sms_type="message from script"
                if dr_update.include?("sender")
                  dr.to=dr_update["sender"]
                end
                dr.user_id=User.where(:admin=>true, :email=>"admin@openbgs.com").first.id

                if dr.save
                  updated_count += 1
                  dr_array << dr
                  ActionSmser::Logger.info("Gateway_commit updated item with id: #{msg_id}, params: #{dr_update.inspect}")
                else
                  ActionSmser::Logger.info("Gateway_commit problem updating item with id: #{msg_id}, params: #{dr_update.inspect}")
                end
            else
                dr = ActionSmser::DeliveryReport.where(:msg_id => msg_id).first

                if dr
                  dr_update.each_pair do |key, value|
                    dr.send("#{key}=", value) if dr.attribute_names.include?(key.to_s)
                  end

                  if dr.save
                    updated_count += 1
                    dr_array << dr
                    ActionSmser::Logger.info("Gateway_commit updated item with id: #{msg_id}, params: #{dr_update.inspect}")
                  else
                    ActionSmser::Logger.info("Gateway_commit problem updating item with id: #{msg_id}, params: #{dr_update.inspect}")
                  end
                else
                  ActionSmser::Logger.info("Gateway_commit not found item with id: #{msg_id}, params: #{dr_update.inspect}")
                end
            end
          end
        end

        begin
          ActionSmser.delivery_options[:gateway_commit_observers].each do |observer|
            observer.after_gateway_commit(dr_array)
          end
        rescue Exception => e
          ActionSmser::Logger.error("Problem with gateway_commit_observers: #{e}")
        end


      end

      if updated_count > 0
        render :text => "Updated info for #{updated_count} items"
      else
        render :text => "Not saved"
      end
    end

    def summary
    end

    def index
      @delivery_reports = ActionSmser::DeliveryReport.from_user(selected_user).latest.paginate(:page => params[:page], :per_page => items_within_page)
    end

    def message_deliveries
      finder = MessageClassAndIdFinder.new(%w(single bulk))
      type, id = finder.execute {|class_name| params["#{class_name}_id"]}
      Rails.logger.info "type: #{type} -- id:#{id}"
      query = MessageDeliveriesQuery.new(type, id, ActionSmser::DeliveryReport.from_user(current_user).latest)
      @delivery_reports = query.find_each
      #paginate(:page => params[:page], :per_page => items_within_page)
    end

    def failed_numbers
      numbers = selected_user.delivery_reports.where.not(status: ActionSmserUtils::DELIVERED_STATUS).distinct.pluck(:to)
      data = numbers.join("\n")
      send_data data, filename: "failed_numbers_#{ I18n.localize(Date.current, :format => :short)}.txt"
    end

    private
      def selected_user
        @user ||= (current_user.admin && params[:user] && User.find(params[:user]) || current_user)
      end

      def items_within_page
        params[:per_page] || 20
      end

      def set_delivery_report
        @delivery_report = ActionSmser::DeliveryReport.find(params[:id])
      end

      def admin_access_only
        if !ActionSmser.delivery_options[:admin_access].blank? && ActionSmser.delivery_options[:admin_access].send(:admin_access, self)
          return true
        else
          render :text => "Forbidden, only for admins", :status => 403
          return false
        end
      end
  end
end
