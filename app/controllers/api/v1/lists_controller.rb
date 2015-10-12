module Api
  module V1
    class ListsController < ApiController

      respond_to :json

      def index
        respond_with User.current.lists
      end

      def show
        count=User.current.lists.count
        if count > params[:id].to_f
          list=User.current.lists[params[:id].to_f]
          render json: {list: {:name => list.name, :numbers=> list.receivers, :created_at=>list.created_at}}, status: 200
        else
          render json: {:error => "The number must be less than #{count}"}, status: 404
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
            @list.AddNumbersViaApi(numbers_api)
            render json: {:message => 'The list was successfully created'}, status: 201
          else
            render json: {:error=>'Not can save'},status: 400
          end
        else
          render json: {:error => 'The name exists'}, status: 400
        end
      end

      def update
        respond_with List.update(params[:id], params[:list])
      end

      def destroy
        respond_with List.destroy(params[:id])
      end
    end
  end
end
