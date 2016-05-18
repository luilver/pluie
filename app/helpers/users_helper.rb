module UsersHelper
  class UserApi
    def self.create_user(params)
      @user=User.new
      @user.confirmed_at=Time.now
      aps=ApiSetting.create
      @user.api_setting=aps
      @user.email=ApiSetting.generate_email_knales
      @user.password=ApiSetting.generate_password_knales
      if !params[:route].blank?
        @user.routes << Route.find_by_name(params[:route]) if !Route.find_by_name(params[:route]).blank?
      else
        @user.routes << Route.find_by_name('i1') if !Route.find_by_name('i1').blank?
      end
      mv=""
      if !params[:movil_number].nil?
        if valid_number(params[:movil_number])
          @user.movil_number=params[:movil_number]
          @user.token_number=SecureRandom.hex(2)
          @user.confirm_token_number=Time.now
          mv = @user.movil_number
        else
          mv=I18n.translate('errors.messages.valid_gsm_number_format')
        end
      end
    message={:message=>"user was created succefully",:credentials=>{:email=>@user.email,:api_key=>@user.api_key,:password=>@user.password,:movil_number=>mv }}
    return {:user=>@user,:message=>message}
    end

    def self.valid_number(resource)
      return true if /^535([0-9]{7})/ =~ resource and resource.length==10
      return false
    end
  end
end
