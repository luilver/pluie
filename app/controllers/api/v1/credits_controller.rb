module Api
  module V1
    class CreditsController < ApiController

      respond_to :json

      def index
        if User.current.admin
        render json: {:all_credits=> User.all.select{|u| u.credit>0}.map{|c| {:email=>c.email, :credits=>c.credits.map{|cu| {:balance=>cu.balance, :description=>cu.description, :date=>cu.created_at}}}}}, status: 200
        else
          render json: {:message=>"You don't have permisions for this resource"}, status: 401
        end
      end

      def show
        if User.current.admin
          if not Credit.find_by_id(params[:id]).blank?
            credit =Credit.find_by_id(params[:id])
            render  json: {:credit=>{:email=>credit.user.email,:balance=>credit.balance,:description=>credit.description,:date=>credit.created_at,:identifier=>credit.id}},status: 200
          else
            render json: {:message=> "Not exists credits with that id"}, status: 404
          end
          else
          render json: {:message=>"You don't have permisions for this resource"}, status: 401
        end
      end

      def by_name_email
        if User.current.admin
          if not User.find_by_email(params[:user][:email]).blank?
            user =User.find_by_email(params[:user][:email])
            render  json: {:user_credits=>{:email=>user.email,:credits=> user.credits.map{|c| {:balance=>c.balance,:description=>c.description, :date=>c.created_at}}}},status: 200
          else
            render json: {:message=> "Not exists credits with that id"}, status: 404
          end
        else
          render json: {:message=>"You don't have permisions for this resource"}, status: 401
        end
      end

      def create
        if User.current.admin
            @credit=Credit.new(:balance=>params[:credit][:balance],:description=>params[:credit][:description])
            if not User.find_by_email(params[:credit][:email]).blank?
              @credit.user=User.find_by_email(params[:credit][:email])
              render json: {:message=>"the credit has been created"},status: 201
            else
              render json: {:message=>"Not exists user with that email"}, status: 404
            end
        else
          render json: {:message=>"You don't have permisions for this resource"}, status: 401
        end
      end

      def update
        if User.current.admin
          if not Credit.find_by_id(params[:id]).blank?
            @credit=Credit.find_by_id(params[:id])
            @credit.description=params[:credit][:description] unless (params[:credit][:description]).blank?
            @credit.balance=params[:credit][:balance] unless (params[:credit][:balance]).blank?
            @credit.save
            render json: {:message=>"the credit has been update"},status: 200
          else
            render json: {:message=>"Not exists credit with that email"}, status: 404
          end
        else
          render json: {:message=>"You don't have permisions for this resource"}, status: 401
        end
      end

      def destroy
        if User.current.admin
          if not Credit.find_by_id(params[:id]).blank?
            @credit=Credit.find_by_id(params[:id])
            @credit.destroy
            render json: {:message=>"the credit has been removed"},status: 200
          else
            render json: {:message=>"Not exists credit with that id"}, status: 404
          end
        else
          render json: {:message=>"You don't have permisions for this resource"}, status: 401
        end
      end
    end
  end
end
