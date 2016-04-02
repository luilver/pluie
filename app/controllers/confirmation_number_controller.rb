class ConfirmationNumberController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:confirmation, :get_api, :reconfirmed,:delete_warning]

  def new
    @errors=nil
    if current_user.movil_number.blank?
      redirect_to main_app.edit_user_registration_path, :notice => I18n.translate('not_phone')
    end
  end

  def new_api
  end


  def get_api
    current_user.api_setting.reset_authentication_token! if !current_user.api_setting.nil?
    if current_user.api_setting.nil?
      api_setting_x=ApiSetting.new({user_id: current_user.id})
      api_setting_x.save
    end
    redirect_to  main_app.edit_user_registration_path
  end

  def reconfirmed
    if !current_user.movil_number.blank?
      ApplicationHelper::ManageSM.new.message_of_confirmation(current_user,current_user.movil_number)
      redirect_to main_app.edit_user_registration_path
    else
      redirect_to main_app.edit_user_registration_path, :notice => 'El usuario no tiene numbero movil'
    end
  end

  def delete_warning
    current_user.low_account=nil
    current_user.save
    redirect_to main_app.edit_user_registration_path, :notice => I18n.translate('low_account_delete')
  end
end