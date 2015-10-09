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
        respond_with List.create(params[:list])
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
