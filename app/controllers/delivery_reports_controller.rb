class DeliveryReportsController < ApplicationController

  def gateway_commit

    updated_count = 0


    if !DeliveryMethods.delivery_options[:gateway_commit].blank? &&
        !DeliveryMethods.delivery_options[:gateway_commit][params['gateway']].blank?

      Rails.logger.info("Gateway_commit found parser for gateway: #{params['gateway']}")

      dr_var_array = DeliveryMethods.delivery_options[:gateway_commit][params['gateway']].send(:process_delivery_report, params)
      dr_array = []

      if !dr_var_array.blank?
        dr_var_array.each do |dr_update|
          msg_id = dr_update["msg_id"]
          dr = DeliveryReport.where(:msg_id => msg_id).first

          if dr
            dr_update.each_pair do |key, value|
              dr.send("#{key}=", value) if dr.attribute_names.include?(key.to_s)
            end

            if dr.save
              updated_count += 1
              dr_array << dr
              Rails.logger.info("Gateway_commit updated item with id: #{msg_id}, params: #{dr_update.inspect}")
            else
              Rails.logger.info("Gateway_commit problem updating item with id: #{msg_id}, params: #{dr_update.inspect}")
            end
          else
            Rails.logger.info("Gateway_commit not found item with id: #{msg_id}, params: #{dr_update.inspect}")
          end
        end
      end

      begin
        DeliveryMethods.delivery_options[:gateway_commit_observers].each do |observer|
          observer.after_gateway_commit(dr_array)
        end
      rescue Exception => e
        Rails.logger.error("Problem with gateway_commit_observers: #{e}")
      end


    end

    if updated_count > 0
      render :text => "Updated info for #{updated_count} items"
    else
      render :text => "Not saved"
    end
  end


  def index

  end

  def show

  def new
    @delivery_report = DeliveryReport.new
  end

  def create
    @delivery_report = DeliveryReport.new(delivery_report_params)
    @delivery_report.user = current_user
  end

  end

  def list

  end

end
