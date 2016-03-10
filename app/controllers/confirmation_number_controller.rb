class ConfirmationNumberController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:confirmation, :get_api]

  def new
    @errors=nil
    if current_user.movil_number.blank?
      redirect_to main_app.edit_user_registration_path, :notice => I18n.translate('not_phone')
    end
  end

  def new_api
  end

  def confirmation
    respond_to do |format|
      @confimation=params[:confirmation][:confirmation]
      if Devise.secure_compare(@confimation,current_user.token_number)
        current_user.confirm_token_number=Time.now
        current_user.save
        format.html
      else
        @errors='Clave incorrecta'
        format.html {render :new}
      end
    end

  end

  def get_api
    current_user.api_setting.reset_authentication_token!
    redirect_to  main_app.edit_user_registration_path
  end
end
