require 'test_helper'
require 'json'

module Api
  module V1
    class UsersControllerTest < ActionController::TestCase


      def setup
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @request.headers['Accept'] = Mime::JSON
        @request.headers['Content-Type'] = Mime::JSON.to_s
      end

      test "usr balance" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        resp =get :balance
        assert_response 200
        assert_equal users(:apiu).balance, JSON.parse(resp.body)['user']['balance'].to_i
      end

      test "user index" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        resp =get :index
        assert_response 200
        assert_equal User.all.count, JSON.parse(resp.body)['count'].to_i
      end

      test "user index unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        resp =get :index
        assert_response 401
      end

      test "user show" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:id=>5}
        resp =get :show,data_params
        assert_response 200
        assert_equal 'ale5@gmail.com', JSON.parse(resp.body)['user']['email']
      end

      test "user show wrong parameter" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:id=>198}
        resp =get :show,data_params
        assert_response 422
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        resp =get :show, {:id=>5}
        assert_response 401
      end

      test "create user OK" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:user=>{:admin=>false,:email=>'aletest@gmail.com',:password=>'DDDDDDDD',:password_confirmation=>'DDDDDDDD',:credit=>'100'}}
        assert_difference('User.count') do
          resp = post :create, data_params
          assert_response 201
          assert_equal 0, User.find_by_email('aletest@gmail.com').balance
        end
      end

      test "create user errors" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:user=>{:admin=>false,:email=>'aletest@gmail.com',:password=>'DDDD1DDDD',:password_confirmation=>'DDDDDDDD',:credit=>'100'}}
        assert_no_difference('User.count') do
          resp = post :create, data_params
          assert_response 422
        end
      end

      test "create user unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:user=>{:admin=>false,:email=>'aletest@gmail.com',:password=>'DDDDDDDD',:password_confirmation=>'DDDDDDDD',:credit=>'100'}}
        resp = post :create, data_params
        assert_response 401
      end

      test "update user OK" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:user=>{:admin=>true,:email=>'ale5@gmail.com',:password=>'pass567899',:password_confirmation=>'pass567899',:credit=>'1020'}}
        assert_no_difference('User.count') do
          resp = put :update, data_params
          assert_response 202
          assert_equal 25, User.find_by_email('ale5@gmail.com').balance
          assert_equal true, users(:apiu).admin
        end
      end

      test "update user wrong" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:user=>{:admin=>false,:password=>'pass56789',:password_confirmation=>'pass56789',:credit=>'1020'}}
        put :update,data_params
        assert_response 404
        data_params={:user=>{:admin=>false,:email=>'ale555aa@gmaidl.com',:password=>'pass56789',:password_confirmation=>'pass56789',:credit=>'1020'}}
        put :update,data_params
        assert_response 422
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        put :update, data_params
        assert_response 401
      end

      test "destroy user ok" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:user=>{:email=>'ale5@gmail.com'}}
        assert_difference 'User.count', -1  do
          delete :destroy,data_params
          assert_response 301
        end
      end

      test "destroy user" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:user=>{:email=>''}}
        assert_no_difference 'User.count'  do
          delete :destroy,data_params
          assert_response 404
        end
        data_params={:user=>{:email=>'ale54546a@gmail.com'}}
        delete :destroy, data_params
        assert_response 422
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:user=>{:email=>'ale5@gmail.com'}}
        delete :destroy,data_params
        assert_response 401
      end

      test "usr balance with authenticate in body" do
        data_params={ :authenticate_api=>{:email=>'ale5@gmail.com',:api_key=>'561b7ec89b0ca61b250815b24e398ae'}}
        resp =get :balance, data_params
        assert_response 200
        assert_equal users(:apiu).balance, JSON.parse(resp.body)['user']['balance'].to_i
      end

      test "authenticate in body wrong" do
        data_params={ :authenticate_api=>{:email=>'ale5@gmail.com',:api_key=>'XX561b7ec89b0ca61b250815b24e398ae'}}
        resp =get :balance, data_params
        assert_response 401
        data_params={ :authenticate_api=>{:email=>'',:api_key=>'561b7ec89b0ca61b250815b24e398ae'}}
        resp =get :balance, data_params
        assert_response 400
        data_params={ :authenticate_api=>{:email=>'eafa@gmail.com',:api_key=>'561b7ec89b0ca61b250815b24e398ae'}}
        resp =get :balance, data_params
        assert_response 400
      end
    end
  end
end
