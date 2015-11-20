require 'test_helper'
require 'json'

module Api
  module V1
    class CreditsControllerTest < ActionController::TestCase


      def setup
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @request.headers['Accept'] = Mime::JSON
        @request.headers['Content-Type'] = Mime::JSON.to_s
      end

      test "test the action index" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        resp= get :index
        assert_response 200,resp.body
      end

      test "test the action index not admin do request" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        resp= get :index
        assert_response 401,resp.body
      end

      test "test the action show" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:id=>21}
        resp = get :show,data_params
        assert_response 200,resp.body
        assert_equal 5, JSON.parse(resp.body)['credit']['balance'].to_i
      end

      test "test the action show invalid indentifier" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:id=>26}
        resp = get :show,data_params
        assert_response 422,resp.body
      end

      test "test the action show unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:id=>20}
        resp = get :show,data_params
        assert_response 401,resp.body
      end

      test "test the action by_name_email OK" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:user=>{:email=>'ale5@gmail.com'}}
        resp = post :by_name_email,data_params
        assert_response 200,resp.body
        assert_equal users(:apiu).credits.count, JSON.parse(resp.body)['user_credits']['count']
      end

      test "test the action show name email blank" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:user=>{:email=>''}}
        resp = post :by_name_email,data_params
        assert_response 404,resp.body
      end

      test "test the action show name email invalid" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:user=>{:email=>'ale555@gmail.com'}}
        resp = post :by_name_email,data_params
        assert_response 422,resp.body
      end

      test "test the action show name email unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:user=>{:email=>'ale5@gmail.com'}}
        resp = post :by_name_email,data_params
        assert_response 401,resp.body
      end

      test "test create OK" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:credit=>{:email=>'ale5@gmail.com',:balance=>16,:description=>"credit of test"}}
        assert_difference('Credit.count') do
          post :create, data_params
        end
        assert_response 201
        assert_equal 41, users(:apiu).credit.to_i
      end

      test "test create email blank" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:credit=>{:email=>'',:balance=>16,:description=>"credit of test"}}
        resp=post :create, data_params
        assert_response 404
      end

      test "test create email wrong" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:credit=>{:email=>'ale5555@gmail.com',:balance=>16,:description=>"credit of test"}}
        resp=post :create, data_params
        assert_response 422
      end

      test "test create unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:credit=>{:email=>'ale5@gmail.com',:balance=>16,:description=>"credit of test"}}
        resp=post :create, data_params
        assert_response 401
      end

      test "test update ok" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:id=>20,:credit=>{:balance=>3,:description=>"credit of test"}}
        assert_no_difference ('Credit.count') do
            put :update, data_params
        end
        assert_response 200
        assert_equal 8, users(:apiu).credit.to_i
      end

      test "test update balance blank" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:id=>20,:credit=>{:balance=>'',:description=>"credit of test"}}
        resp= put :update, data_params
        assert_response 422
        data_params={:id=>20,:credit=>{:description=>"credit of test"}}
        assert_response 422
      end

      test "test update balance id wrong" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:id=>267,:credit=>{:balance=>5,:description=>"credit of test"}}
        resp= put :update, data_params
        assert_response 422
      end

      test "test update unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:id=>20,:credit=>{:balance=>16,:description=>"credit of test"}}
        resp=put :update, data_params
        assert_response 401
      end

      test "Destroy credit" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:id=>20}
        assert_difference 'Credit.count', -1 do
          resp= delete :destroy,data_params
        end
        assert_response 301
      end

      test "Destroy invalid id" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:id=>26}
        resp= delete :destroy,data_params
        assert_response 422
      end

      test "Destroy unautorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:id=>20}
        resp= delete :destroy,data_params
        assert_response 401
        assert_equal "Unauthorized", JSON.parse(resp.body)['message']
      end
    end
  end
end

