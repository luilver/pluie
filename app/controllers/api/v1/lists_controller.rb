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
          render json: {:error => "Not exists list with that id"}, status: 404
        end
      end

      def create
        numbers_api=params[:list][:numbers]
        name =params[:list][:name]

        @list=List.new
        @list.user = User.current
        @list.name=name

        if not User.current.lists.find_by_name(name)
          if @list.save(:validate=>false)
            @list.addNumbersViaApi(numbers_api)
            render json: {:message => 'The list was successfully created'}, status: 201
          else
            render json: {:error=>'Not can save'},status: 400
          end
        else
          render json: {:error => 'The name exists'}, status: 400
        end
      end

      def update
        if @list = User.current.lists.find_by_name(params[:list][:name])
          if params[:list][:remove]
            @list.deleteNumbers(params[:list][:numbers])
            render json: {:message=>'The list was successfully update', :option=>'remove'}, status: 200
          else
            @list.addNumbersViaApi(params[:list][:numbers])
            render json: {:message=>'The list was successfully update', :option=>'add'}, status: 200
          end
        else
          render json: {:error => 'The name does not exist'}, status: 404
        end
      end

      def destroy
          if @list= User.current.lists.find_by_name(params[:list][:name])
            @list.destroy
            render json: {:message=>"Destroy list: #{params[:list][:name]}"}, status: 410
          else
            render json: {:error => 'The name does not exist'}, status: 404
          end
      end
    end
  end
end
