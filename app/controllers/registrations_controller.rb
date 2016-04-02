
class RegistrationsController <  Devise::RegistrationsController

    def new
      @notice_notified=params[:notice]
      super
    end

    def update
      current_user.url_callback=params[:url][:url] unless params[:url][:url].blank?
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
      self.resource.url_callback=params[:url][:url] unless params[:url][:url].blank?
      self.resource.movil_number=params[:movil_number][:movil_number] unless params[:movil_number][:movil_number].blank? or !valid_number(params[:movil_number][:movil_number]) or !other_movil_number
      if params[:low_a_check][:low_a_check].to_i==1
        self.resource.low_account =params[:low_account][:low_account]  unless params[:low_account][:low_account].blank? or !validate_integer(params[:low_account][:low_account])
      end
      prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
      conf_number = confirmation if !params[:confirm_number].blank?
      if conf_number==false
          self.resource.errors[:base]='Confirmacion no valida'
          clean_up_passwords resource
          respond_with resource
      else
        if !valid_number(params[:movil_number][:movil_number])
          self.resource.errors[:base]=I18n.translate('errors.messages.valid_gsm_number_format').html_safe
          clean_up_passwords resource
          respond_with resource
        else
          resource_updated = update_resource(resource, account_update_params)
          yield resource if block_given?
          if resource_updated
            if is_flashing_format?
              flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
                  :update_needs_confirmation : :updated
              set_flash_message :notice, flash_key
            end
            ApplicationHelper::ManageSM.new.message_of_confirmation(self.resource,self.resource.movil_number) if !params[:movil_number][:movil_number].blank? and self.resource.confirm_token_number.nil? and self.resource.token_number.blank?
            sign_in resource_name, resource, bypass: true
            respond_with resource, location: after_update_path_for(resource)
          else
            clean_up_passwords resource
            respond_with resource
          end
        end
      end
    end


    def valid_number(resource)
        return true if resource.blank?
        return true if /^535([0-9]{7})/ =~ resource and resource.length==10
        return false
    end

    def validate_integer(num)
        begin
          Float num
          return true
        rescue
          return false
        end
    end

    def confirmation
        @confimation= params[:confirm_number][:confirm_number]
        if @confimation!=""
          if Devise.secure_compare(@confimation,resource.token_number)
            self.resource.confirm_token_number=Time.now
            return true
          else
            return false
          end
        else
          return true
        end
    end

    def other_movil_number
      number_p= params[:movil_number][:movil_number]
      if !number_p.blank?
        if self.resource.movil_number!= number_p
          self.resource.confirm_token_number=nil
          self.resource.token_number=nil
          return true
        else
          return false
        end
      end
      return false
    end
end
