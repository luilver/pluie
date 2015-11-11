module Api
  module V1
    class SearchListsController < ApiController


      respond_to :json

      def index  #servicio que devuelve los nombres de todas las listas del usuario y la cantidad lists: {name:[name,...]}
        @name=[]
        User.current.lists.each do |l|
          @name <<  {:date=> l.created_at.to_date,:name=>l.name, :identifier=>l.id}
        end
        render json: {:lists => {:count => User.current.lists.count,:data=> @name}}, status: 200
      end

      def searchlists #servicio que devuelve los numeros de las listas que el usuario pidio
        name=[]
        notFoundName=[]
        return (render json: {:message=>"invalid blank list name"},status: 404) if params[:lists][:name].blank?
        params[:lists][:name].each do |n|
          if User.current.lists.find_by_name(n)
            name << {:name => n, :numbers => User.current.lists.find_by_name(n).receivers}
          else
            notFoundName << {:name=> n, :error => 'name invalid '}
          end
        end
        if notFoundName.blank?
          notFoundName << {:success => 'succefully send list'}
        end
        if name.blank?
          render json: {:message=>'invalid list name' , :notFound =>notFoundName }, status: 422
        else
        render json: {:lists=> name, :notFound =>notFoundName }, status: 200
        end
      end
    end
  end
end
