module Api
  module V1
    class UsersController < ApiController

      respond_to :json

      def balance
        render json: {:user=>{:email=>User.current.email, :balance=>User.current.balance}},status: 200
      end

      def index
        if User.current.admin
          render json: {:users=>User.all.map{|u| {:email=>u.email,:balance=>u.balance,:Gasto_Total=>u.spent}}},status: 200
        else
          render json: {:message=>"you don't have permission for this resource"},status: 401
        end
      end

      def show
        if User.current.admin
          if not User.find_by_id(params[:id]).blank?
            render json: {:user=>{:email=>User.find_by_id(params[:id]).email,:balance=>User.find_by_id(params[:id]).balance}},status: 200
          else
            render json: {:message=>'Not exists user with that id'},status: 404
          end
        else
            render json: {:message=>"you don't have permission for this resource"},status: 401
        end
      end

      def create
        if User.current.admin
          @user=User.new(user_params)
          @user.confirmed_at=DateTime.now

          if @user.save
           render json: {:message=>"The user was created succefully"}, status: 201
          else
            render json: @user.errors, status: :unprocessable_entity
          end
        else
          render json: {:message=>"you don't have permission for this resource"},status: 401
        end
      end

      def update
        respond_with User.update(params[:id], params[:user])
      end

      def destroy
        respond_with User.destroy(params[:id])
      end

      protected

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :admin, :credit, :locale)
      end
    end
  end
end
