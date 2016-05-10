module Api
  module V1

  class RegistrationsController < Devise::RegistrationsController
    protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/api.knales.v' }
    before_filter :authenticate_admin!
    respond_to :json

    def create
       build_resource(sign_up_params)
       resource.confirmed_at=DateTime.now
       resource.routes << Route.find_by_name('i1') if !Route.find_by_name('i1').blank?
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

    def authenticate_admin!
      return (render json: {:message=>"The email is blank"}, status: 404) unless not request.headers["HTTP_EMAIL"].blank?
      return (render json: {:message=>"The api key is blank"}, status: 404) unless not request.headers["HTTP_API_KEY"].blank?


         if user=User.find_by_email(request.headers["HTTP_EMAIL"])
           if Devise.secure_compare(user.api_key,  request.headers["HTTP_API_KEY"])
             if user.admin
               return
             else
               render json: {:message=>"Unauthorized"},status: 401
             end
           else
             render json: {:message=>"Invalid Api key"}, status: 422
           end
         else
          render json: {:message=>"Invalid email"}, status: 422
         end
    end
  end
end
end
