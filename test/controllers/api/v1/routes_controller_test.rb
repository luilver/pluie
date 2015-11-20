require 'test_helper'
require 'json'

module Api
  module V1
    class RoutesControllerTest < ActionController::TestCase


      def setup
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @request.headers['Accept'] = Mime::JSON
        @request.headers['Content-Type'] = Mime::JSON.to_s
      end

      test "test the action index" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        resp = get :index
        assert_response 200
      end

      test "test the action index unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        resp= get :index
        assert_response 401
      end

      test "test the action show" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:id=>19}
        resp= get :show,data_params
        assert_response 422
      end

      test "test the action show ok" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:id=>21}
        resp= get :show,data_params
        assert_response 200, resp.body
        assert_equal 'goldA', JSON.parse(resp.body)['route']['name_route']
      end

      test "test the action show unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:id=>19}
        resp= get :show,data_params
        assert_response 401
      end



     end
  end
end

