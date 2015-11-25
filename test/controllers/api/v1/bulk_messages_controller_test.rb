require 'test_helper'
require 'json'

module Api
  module V1
    class BulkMessagesControllerTest < ActionController::TestCase


      def setup
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @request.headers['Accept'] = Mime::JSON
        @request.headers['Content-Type'] = Mime::JSON.to_s
      end

      test "test the action index" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'

        resp =get :index
        assert_response 200, resp.body
        assert_equal 'messgApi index', JSON.parse(resp.body)['bulk_messages'][0]['messages']
        assert_equal 2,  JSON.parse(resp.body)['bulk_messages'].count
        assert_equal 23,  JSON.parse(resp.body)['bulk_messages'][0]['numbers'].to_i
      end

      test "test the action show" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:id=>12}
        resp = get :show, data_params
        assert_response 200
        assert_equal "Gold", JSON.parse(resp.body)['bulk_message']['route']
      end

      test "test action show id wrong" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:id=>135}
        resp = get :show, data_params
        assert_response 422
      end

      test "send bulk message" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:bulk_message=>{:message=>"send test message",:route=>'Gold',:list_names=>["five"]}}
        assert_difference('BulkMessage.count') do
          resp = post :create, data_params
        end
        assert_response 201
      end

      test "send bulk message params blanls" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:bulk_message=>{:message=>"",:route=>'Gold',:list_names=>["five"]}}
        resp = post :create, data_params

        assert_response 404
        data_params={:bulk_message=>{:message=>"message",:list_names=>["five"]}}
        resp = post :create, data_params
        assert_response 404
        data_params={:bulk_message=>{:message=>"message test",:route=>'Gold'}}
        resp = post :create, data_params
        assert_response 404
      end

      test "send bulk route wrong" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:bulk_message=>{:message=>"message test",:route=>'Gold11XX',:list_names=>["five"]}}
        resp = post :create, data_params
        assert_response 422
      end

      test "send bulk not credit" do
        @request.headers["HTTP_EMAIL"]= 'notcredit@gmail.com'
        @request.headers["HTTP_API_KEY"] = '56yb7ec89b0ca61b250815b24e408n1'
        data_params={:bulk_message=>{:message=>"message test",:route=>'Gold',:list_names=>["bulk"]}}
        resp = post :create, data_params
        assert_response 422, resp.body
      end

      test "destroy bulk message id wrong" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:id=>18}
        resp = delete :destroy, data_params
        assert_response 422, resp.body
      end

      test "destroy  bulk message unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'notcredit@gmail.com'
        @request.headers["HTTP_API_KEY"] = '56yb7ec89b0ca61b250815b24e408n1'
        data_params={:id=>12}
        resp = delete :destroy, data_params
        assert_response 401, resp.body
      end

      test "destroy bulk message" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        data_params={:id=>12}
        resp = delete :destroy, data_params
        assert_response 301, resp.body
      end
    end
  end
end

