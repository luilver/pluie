require 'test_helper'
require 'json'
require 'webmock'


module Api
  module V1
    class SingleMessagesControllerTest < ActionController::TestCase

      fixtures :all

      def setup
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @request.headers['Accept'] = Mime::JSON
        @request.headers['Content-Type'] = Mime::JSON.to_s
      end

      test "action index" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        resp = get :index
        assert_response 200, resp.body
      end

      test "action show" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:id=>14}
        resp = get :show,data_params
        assert_response 200, resp.body
        assert JSON.parse(resp.body)['number'].include?('5358428432')
      end

      test "action show wrong parameters" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:id=>146}
        resp = get :show,data_params
        assert_response 422, resp.body
      end

      test "create single message wrong parameters" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:single_message=>{:message=>"message test to api", :route=>'golAAdA',:numbers=>['5351627143']}}
        resp = post :create , data_params
        assert_response 422, resp.body
        data_params={:single_message=>{ :route=>'golAAdA',:numbers=>['5351627143']}}
        resp = post :create , data_params
        assert_response 404, resp.body
        data_params={:single_message=>{:message=>"message test to api" ,:numbers=>['5351627143']}}
        resp = post :create , data_params
        assert_response 404, resp.body
        data_params={:single_message=>{:message=>"message test to api" ,:route=>'GoldA',:numbers=>['5451627143']}}
        resp = post :create , data_params
        assert_response 422, resp.body
      end

      #error en environmet development and test
      # test "create single message ok" do
      #   @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
      #   @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
      #   data_params={:single_message=>{:message=>"message test to api", :route=>'goldA',:numbers=>['5351627143']}}
      #   resp = post :create , data_params
      #   assert_response 200, resp.body
      # end

      test "destroy single message" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params= {:id=>14}
        resp = delete :destroy , data_params
        assert_response 301, resp.body
      end

      test "destroy single message wrong parameters" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params= {:id=>14}
        resp = delete :destroy , data_params
        assert_response 401, resp.body
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:id=>161}
        delete :destroy,data_params
        assert_response 422
      end

      test "send single message with authenticate in body" do
        WebMock.disable!
        resp=''
        data_params={:authenticate_api=>{:email=>'ale5@gmail.com',:api_key=>'561b7ec89b0ca61b250815b24e398ae'},:single_message=>{:message=>"send test message",:route=>'Gold',:numbers=>["5356789032"]}}
        assert_difference('SingleMessage.count') do
          resp = post :create, data_params
        end
        assert_response 200,resp.body
      end

      test "destroy single message wrong parameters with authenticate in body" do
        data_params= {:id=>14,:authenticate_api=>{:email=>'admin40@gmail.com',:api_key=>'561b7ec89b0ca61b250815b24e408a14'}}
        resp = delete :destroy , data_params
        assert_response 401, resp.body
        data_params={:id=>161,:authenticate_api=>{:email=>'admin40@gmail.com',:api_key=>'561b7ec89b0ca61b250815b24e408a1'}}
        delete :destroy,data_params
        assert_response 422
      end

      test "action show wrong parameters with authenticate in body" do
        data_params={:id=>146,:authenticate_api=>{:email=>'ale5@gmail.com',:api_key=>'561b7ec89b0ca61b250815b24e398ae'}}
        resp = get :show,data_params
        assert_response 422, resp.body
      end

      test "wrong api_key" do
        data_params={:id=>146,:authenticate_api=>{:email=>'ale5@gmail.com',:api_key=>'x561b7ec89b0ca61b250815b24e398ae'}}
        resp = get :show,data_params
        assert_response 401, resp.body
        data_params={:id=>146,:authenticate_api=>{:email=>'ale5@gmail.com'}}
        resp = get :show,data_params
        assert_response 400, resp.body
        data_params={:id=>146,:authenticate_api=>{}}
        resp = get :show,data_params
        assert_response 400, resp.body
      end

      test "send single message with authenticate in body wrong" do
        WebMock.disable!
         data_params={:authenticate_api=>{:email=>'ale5@gmail.com',:api_key=>'561b7ec89b0ca61b250815b24e398aeXXXXXX'},:single_message=>{:message=>"send test message",:route=>'Gold',:numbers=>["5356789032"]}}
          resp = post :create, data_params
          assert_response 401,resp.body
      end
    end
  end
end

