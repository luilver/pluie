module Api
  module V1
    class SearchListsController < ApiController
      protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

      respond_to :json

      def index  #servicio que devuelve los nombres de todas las listas del usuario y la cantidad
        User.current =User.find(1)
        @name=[]
        User.current.lists.each do |l|
          @name <<  {:date=> l.created_at.to_date,:name=>l.name}
        end
        render json: {:lists => {:count => User.current.lists.count,:name=> @name}}, status: 200
      end

      def searchlists
        name=[]
        params[:lists][:name].each do |n|
          if List.find_by_name(n)
            name << {:name => n, :numeros => List.find_by_name(n).receivers}
          end
        end
        render json: {:lists=> name }, status: 200
      end

      protected

      def GetNameLists
        name=[]
        User.current.lists.each do |l|
          name <<  l.name
        end
        return name
      end
    end
  end
end
