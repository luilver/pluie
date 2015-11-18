require 'test_helper'
require 'json'

module Api
  module V1
    class ListsControllerTest < ActionController::TestCase


      def setup
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @request.headers['Accept'] = Mime::JSON
        @request.headers['Content-Type'] = Mime::JSON.to_s
        gsm=GsmNumber.new(:number=>53567845357)
        gsm.save

      end

      test "get all list of user" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'

        resp = get :index
        assert_response 200, resp.body
      end

      test "action show list" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'

        resp =get :show, {:id=>100}
        assert_response 200,resp.body
        assert_equal 'six', JSON.parse(resp.body)['list']['name']
      end

      test "action show id wrong" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'

        resp =get :show, {:id=>14}
        assert_response 404,resp.body
      end



    end
    end
  end

