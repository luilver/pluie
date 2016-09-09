module Api
  module V1
    class ListsController < ApiController

      respond_to :json

      def index
        respond_with User.current.lists
      end

      def show
        if not User.current.lists.find_by_id(params[:id]).blank?
          list=User.current.lists.find_by_id(params[:id])
          render json: {list: {:name => list.name, :numbers=> list.receivers, :created_at=>list.created_at}}, status: 200
        else
          log_not_authorized_access
          render json: {:error => "identifier #{params[:id]} invalid"}, status: 422
        end
      end

      def create
        numbers_api=params[:list][:numbers]
        name =params[:list][:name]

        @list=List.new
        @list.user = User.current
        @list.name=name
        return (render json: {:message=>"name is blank"},status: 404) if params[:list][:name].blank?
        return (render json: {:message=>"numbers is empty"},status: 422) if params[:list][:numbers].blank?
        if not User.current.lists.find_by_name(name)
          if @list.save(:validate=>false)
            @list.addNumbersViaApi(numbers_api)
            render json: {:message => 'List was successfully created'}, status: 201
          else
            render json: @list.errors, status: 422
          end
        else
          log_not_authorized_access
          render json: {:error => 'name list invalid'}, status: 422
        end
      end

      def update
        return (render json: {:message=>"name is blank"},status: 404) if params[:list][:name].blank?
        if @list = User.current.lists.find_by_name(params[:list][:name])
          if params[:list][:remove]
            @list.deleteNumbers(params[:list][:numbers])
            render json: {:message=>'List update successfully', :option=>'remove'}, status: 200
          else
            @list.addNumbersViaApi(params[:list][:numbers])
            render json: {:message=>'The list was successfully update', :option=>'add'}, status: 200
          end
        else
          log_not_authorized_access
          render json: {:error => 'invalid name'}, status: 422
        end
      end

      def destroy
          return (render json: {:message=>"name is blank"},status: 404) if params[:list][:name].blank?
          if not User.current.lists.find_by_name(params[:list][:name]).blank?
            @list= User.current.lists.find_by_name(params[:list][:name])
            @list.destroy
            render json: {:message=>"List: #{params[:list][:name]} removed succefully "}, status: 301
          else
            log_not_authorized_access
            render json: {:error => 'invalid name'}, status: 422
          end
      end
    end
  end
end
