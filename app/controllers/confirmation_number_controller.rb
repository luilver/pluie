class ConfirmationNumberController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :confirmation

  def new
    @errors=nil
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
end
