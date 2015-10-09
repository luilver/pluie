module Api
  module V1
    class SearchListsController < ApiController

      respond_to :json

      def index  #servicio que devuelve los nombres de todas las listas del usuario y la cantidad
        User.current =User.find(1)
        @name=[]
        User.current.lists.each do |l|
          @name <<  {:date=> l.created_at.to_date,:name=>l.name}
        end
        render json: {:lists => {:count => User.current.lists.count,:name=> @name}}
      end



    end
  end
end
