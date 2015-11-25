module Api
  module V1
    class RoutesController < ApiController

      respond_to :json

      def index
        if User.current.admin
         render json: {:routes=>Route.all.map{|r| {:name=>r.name,:price=>r.price,:email=>r.user.email,:gateway=>r.gateway.name,:identifier=>r.id}}}, status: 200
        else
         render json: {:message=>"permission denied"}, status: 401
        end
      end

      def show
        if User.current.admin
            if Route.find_by_id(params[:id])
              route=Route.find_by_id(params[:id])
              render json: {:route=>{:name_route=>route.name,:email=>route.user.email,:gateway=>route.gateway.name,:price=>route.price,:route_intern=>route.system_route}}, status: 200
            else
              render json: {:message=>"invalid identifier: #{params[:id]}"}, status: 422
            end
          else
          render json: {:message=>"permission denied"}, status: 401
        end
      end

      def by_route_name
        return (render json: {:message=>"invalid blank route name"},status: 404) if params[:route][:name_route].blank?
        if User.current.admin
            if Route.where(:name=>params[:route][:name_route]).any?
              render json: {:name_route=>params[:route][:name_route],:routes=>Route.where(:name=>params[:route][:name_route]).map{|r| {:email=>r.user.email,:gateway=>r.gateway.name,:price=>r.price,:identifier=>r.id}}}, status: 200
            else
              render json: {:message=>"invalid name: #{params[:route][:name_route]}"}, status: 422
            end
        else
          render json: {:message=>"permission denied"}, status: 401
        end
      end

      def by_email_user
        return (render json: {:message=>"invalid blank email"},status: 404) if params[:route][:email_user].blank?
        if User.current.admin
          if (not User.find_by_email(params[:route][:email_user]).blank?) && (not User.find_by_email(params[:route][:email_user]).routes.blank?)
              user=User.find_by_email(params[:route][:email_user])
              render json: {:email=>user.email,:routes=>user.routes.map{|r| {:name_route=>r.name, :gateway=>r.gateway.name,:price=>r.price,:identifier=>r.id}}},status: 200
          else
              if User.find_by_email(params[:route][:email_user]).blank?
                render json: {:message=>"invalid blank email"}, status: 422
              else
                render json: {:message => "invalid empty routes"},status: 422
              end
          end
        else
          render json: {:message=>"permission denied"}, status: 401
        end
      end

      def create
        return (render json: {:message=>"invalid blank email"},status: 404) if params[:route][:email_user].blank?
        return (render json: {:message=>"invalid blank gateway"},status: 404) if params[:route][:gateway_name].blank?
        return (render json: {:message=>"invalid blank price"},status: 404) if params[:route][:price].blank?
        return (render json: {:message=>"invalid blank name"},status: 404) if params[:route][:name].blank?
        if User.current.admin
            if (not User.find_by_email(params[:route][:email_user]).blank?) && (not Gateway.find_by_name(params[:route][:gateway_name]).blank?)
              @route=Route.new(:name=>route_params[:name],:price=>route_params[:price],:system_route=>route_params[:system_route])
              @route.user=User.find_by_email(route_params[:email_user])
              @route.gateway=Gateway.find_by_name(route_params[:gateway_name])
                if @route.save
                  render json: {:message=>"route created succefully"}, status: 201
                else
                  render json: @route.errors, status: 422
                end
            else
              if  Gateway.find_by_name(params[:route][:gateway_name]).blank?
                render json: {:message=> "invalid gateway"}, status: 422
              else
                render json: {:message=> "invalid email"}, status: 422
              end
            end
        else
          render json: {:message=>"permission denied"}, status: 401
        end
      end

      def update
        return (render json: {:message=>"invalid blank email"},status: 404) if params[:route][:email_user].blank?
        return (render json: {:message=>"invalid blank gateway"},status: 404) if params[:route][:gateway_name].blank?
        return (render json: {:message=>"invalid blank price"},status: 404) if params[:route][:price].blank?
        return (render json: {:message=>"invalid blank name"},status: 404) if params[:route][:name].blank?
        if User.current.admin
            @route=Route.find(params[:id]) unless Route.find_by_id(params[:id]).blank?
            if @route
              @route.user=User.find_by_email(route_params[:email_user]) unless  User.find_by_email(route_params[:email_user]).blank?
              @route.gateway=Gateway.find_by_name(route_params[:gateway_name]) unless Gateway.find_by_name(route_params[:gateway_name]).blank?
              if  (not Gateway.find_by_name(route_params[:gateway_name]).blank?) && (not User.find_by_email(route_params[:email_user]).blank?)
                params[:route].delete(:email_user)
                params[:route].delete(:gateway_name)
                @route.update(route_params)
                render json: {:message=>"route updated succefully"}, status: 200
              else
                if  Gateway.find_by_name(route_params[:gateway_name]).blank?
                    render json: {:message=> "invalid gateway"}, status: 422
                else
                  render json: {:message=> "invalid email"}, status: 422
                end
              end
            else
              render json: {:message=> "invalid identifier: #{params[:id]}"}, status: 422
            end
        else
          render json: {:message=>"permission denied"}, status: 401
        end
      end

      def destroy
        if User.current.admin
          if not Route.find_by_id(params[:id]).blank?
            @route=Route.find(params[:id])
            @route.destroy
            render json: {:message=>"route removed succefully"}, status: 301
          else
            render json: {:message=> "invalid identifier: #{params[:id]}"}, status: 422
          end
        else
          render json: {:message=>"permission denied"}, status: 401
        end
      end

      private

      def route_params
        params.require(:route).permit(:name, :price, :email_user, :gateway_name, :system_route)
      end
    end
  end
end
