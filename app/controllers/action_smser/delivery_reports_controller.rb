module ActionSmser
  class DeliveryReportsController < Pluie::ApplicationController
    before_filter :admin_access_only, :except => :gateway_commit
    before_action :set_delivery_report, only: [:show]
    load_and_authorize_resource except: [:gateway_commit]
    helper_method :items_within_page

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
      offset = params[:offset].to_i || 0
      offset =  0 if offset < 0
      @delivery_reports = ActionSmser::DeliveryReport.where(:user_id => current_user.id).order('created_at DESC').paginate(:page => params[:page], :per_page => items_within_page)
    end

    private
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
