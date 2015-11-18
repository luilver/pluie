require 'test_helper'
require 'json'

module Api
  module V1
    class RegistrationsControllerTest < ActionController::TestCase


      def setup
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @request.headers['Accept'] = Mime::JSON
        @request.headers['Content-Type'] = Mime::JSON.to_s
      end

      test "create user registration api" do
          @request.headers["HTTP_EMAIL"]='admin40@gmail.com'
          @request.headers["HTTP_API_KEY"]='561b7ec89b0ca61b250815b24e408a1'
          params_sign = {:sign_up_params => {:email=>'ale10@gmail.com',:password=>'DDDDDDDD',:password_confirmation=>'DDDDDDDD'}}
          resp = post :create, params_sign
          assert_response 201, resp.body
      end

      test "no registration email in use" do
        @request.headers["HTTP_EMAIL"]='admin40@gmail.com'
        @request.headers["HTTP_API_KEY"]='561b7ec89b0ca61b250815b24e408a1'
        params_sign = {:sign_up_params => {:email=>'ale5@gmail.com',:password=>'DDDDDDDD',:password_confirmation=>'DDDDDDDD'}}
        resp = post :create, params_sign
        assert_response 422
        resp_json ={:errors=>{:email=>["ya está en uso"]}}.to_json
        assert_equal  resp_json, resp.body
      end

      test "unauthorized user" do
        @request.headers["HTTP_EMAIL"]='ale5@gmail.com'
        @request.headers["HTTP_API_KEY"]='561b7ec89b0ca61b250815b24e398ae'
        params_sign = {:sign_up_params => {:email=>'ale5@gmail.com',:password=>'DDDDDDDD',:password_confirmation=>'DDDDDDDD'}}
        resp = post :create, params_sign
        assert_response 401
      end

      test "invalid Api Key" do
        @request.headers["HTTP_EMAIL"]='admin40@gmail.com'
        @request.headers["HTTP_API_KEY"]='xxxxx561b7ec89b0ca61b250815b24e408a1'
        params_sign = {:sign_up_params => {:email=>'ale5@gmail.com',:password=>'DDDDDDDD',:password_confirmation=>'DDDDDDDD'}}
        resp = post :create, params_sign
        assert_response 422
      end

      test "email is blank"  do
        @request.headers["HTTP_EMAIL"]=""
        @request.headers["HTTP_API_KEY"]='xxxxx561b7ec89b0ca61b250815b24e408a1'
        params_sign = {:sign_up_params => {:email=>'ale5@gmail.com',:password=>'DDDDDDDD',:password_confirmation=>'DDDDDDDD'}}
        resp = post :create, params_sign
        assert_response 404
        data_json_response={:message=>"The email is blank"}.to_json
        assert_equal data_json_response,resp.body
      end

    end
  end
end
