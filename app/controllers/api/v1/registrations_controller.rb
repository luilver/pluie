module Api
  module V1

  class RegistrationsController < Devise::RegistrationsController
    protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/api.knales.v' }
    respond_to :json

    def create
       build_resource(sign_up_params)
       if resource.save
        render json: {:register => 'ok register succefully'}, status: 201, success: true
       else
         respond_with resource
       end
    end

    private

    def sign_up_params
      params.require(:sign_up_params).permit(:email, :password, :password_confirmation)
    end


  end
end
end
