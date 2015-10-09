module Api
  module V1
    class SearchListsController < ApiController
      protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

      respond_to :json

      def index  #servicio que devuelve los nombres de todas las listas del usuario y la cantidad lists: {name:[name,...]}
        User.current=User.find(1)
        @name=[]
        User.current.lists.each do |l|
          @name <<  {:date=> l.created_at.to_date,:name=>l.name}
        end
        render json: {:lists => {:count => User.current.lists.count,:name=> @name}}, status: 200
      end

      def searchlists #servicio que devuelve los numeros de las listas que el usuario pidio
        name=[]
        notFoundName=[]
        params[:lists][:name].each do |n|
          if User.current.lists.find_by_name(n)
            name << {:name => n, :numbers => User.current.lists.find_by_name(n).receivers}
          else
            notFoundName << {:name=> n, :error => 'No existe lista con ese nombre'}
          end
        end
        render json: {:lists=> name, :notFound =>notFoundName }, status: 200
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
