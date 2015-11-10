module Api
  module V1
    class CreditsController < ApiController

      respond_to :json

      def index
        if User.current.admin
        render json: {:all_credits=> User.all.select{|u| u.credit>0}.map{|c| {:email=>c.email, :credits=>c.credits.map{|cu| {:identifier=> cu.id,:balance=>cu.balance, :description=>cu.description, :date=>cu.created_at}}}}}, status: 200
        else
          render json: {:message=> "You are not admin"}, status: 401
        end
      end

      def show
        if User.current.admin
          if not Credit.find_by_id(params[:id]).blank?
            credit =Credit.find_by_id(params[:id])
            render  json: {:credit=>{:email=>credit.user.email,:balance=>credit.balance,:description=>credit.description,:date=>credit.created_at,:identifier=>credit.id}},status: 200
          else
            render json: {:message=> "identifier: #{params[:id]} invalid"}, status: 422
          end

          else
          render json: {:message=>"You are not admin"}, status: 401
        end
      end

      def by_name_email
        return (render json: {:message => "email blank"},status: 404) if (params[:user][:email]).blank?
        if User.current.admin
          if not User.find_by_email(params[:user][:email]).blank?
            user =User.find_by_email(params[:user][:email])
            render  json: {:user_credits=>{:email=>user.email,:credits=> user.credits.map{|c| {:balance=>c.balance,:description=>c.description, :date=>c.created_at}}}},status: 200
          else
            render json: {:message=> "email invalid"}, status: 422
          end
        else
          render json: {:message=>"You are not admin"}, status: 401
        end
      end

      def create
        return (render json: {:message => "email blank"},status: 404) if (params[:credit][:email]).blank?
        if User.current.admin
            @credit=Credit.new(:balance=>params[:credit][:balance],:description=>params[:credit][:description])
            if not User.find_by_email(params[:credit][:email]).blank?
              @credit.user=User.find_by_email(params[:credit][:email])
              if @credit.save
                render json: {:message=>"credit created succefully"},status: 201
              else
                render json: @credit.errors
              end
            else
              render json: {:message=>"email invalid"}, status: 422
            end
        else
          render json: {:message=>"you are not admin"}, status: 401
        end
      end

      def update
        if User.current.admin
          if not Credit.find_by_id(params[:id]).blank?
            @credit=Credit.find_by_id(params[:id])
            @credit.description=params[:credit][:description] unless (params[:credit][:description]).blank?
            @credit.balance=params[:credit][:balance] unless (params[:credit][:balance]).blank?
            @credit.save
            render json: {:message=>"credit update succefully"},status: 200
          else
            render json: {:message=>"identifier: #{params[:id]} invalid"}, status: 422
          end
        else
          render json: {:message=>"you are not admin"}, status: 401
        end
      end

      def destroy
        if User.current.admin
          if not Credit.find_by_id(params[:id]).blank?
            @credit=Credit.find_by_id(params[:id])
            @credit.destroy
            render json: {:message=>"credit removed succefully"},status: 200
          else
            render json: {:message=>"identifier: #{params[:id]} invalid"}, status: 404
          end
        else
          render json: {:message=>"you are not admin"}, status: 401
        end
      end
    end
  end
end
