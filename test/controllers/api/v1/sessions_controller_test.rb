require 'test_helper'
require 'json'

module Api
  module V1
    class SessionsControllerTest < ActionController::TestCase


      def setup
         # @controller = Api::V1::SessionsController.new
         # @request = ActionController::TestRequest.new
         # @response =ActionController::TestResponse.new
         @request.env["devise.mapping"] = Devise.mappings[:user]
         @request.headers['Accept'] = Mime::JSON
         @request.headers['Content-Type'] = Mime::JSON.to_s
      end

      test "create session for user" do
         resp = post :create, {:email=>'ale5@gmail.com', :password=>'pass5678'}
         assert_response 201, resp.body
         assert_equal 5, users(:apiu).id
         #assert_equal  users(:apiu).api_setting.api_key, JSON.parse(resp.body)['api_key']
      end

      test "destroy session for user" do
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        @request.headers["HTTP_EMAIL"] = 'ale5@gmail.com'
        resp = delete :destroy
        assert_response 200, resp.body
      end

      test "email invalid in create session" do
        resp = post :create , {:email => 'ale7@gmail.com',:password=>'pass5678'}
        json_resp= {:success=>false, :message=>'Invalid email'}.to_json
        assert_response 422, JSON.parse(resp.body)
        assert_equal json_resp ,resp.body
      end

      test "password blank" do
        resp = post :create , {:email => "ale5@gmail.com" ,:password=>""}
        json_resp={ success: false, message: 'password missing'}.to_json
        assert_response 404
        assert_equal json_resp ,resp.body
      end

      test "invalid api key in destroy" do
        @request.headers["HTTP_API_KEY"] = 'XXXXXXXX561b7ec89b0ca61b250815b24e398ae'
        @request.headers["HTTP_EMAIL"] = 'ale5@gmail.com'
        resp = delete :destroy
        assert_response 422, resp.body
      end

    end
  end
end
