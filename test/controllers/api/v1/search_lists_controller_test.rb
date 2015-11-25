require 'test_helper'
require 'json'

module Api
  module V1
    class SearchListsControllerTest < ActionController::TestCase


      def setup
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @request.headers['Accept'] = Mime::JSON
        @request.headers['Content-Type'] = Mime::JSON.to_s
      end

      test "test search list index" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        resp = get :index
        assert_response 200
        assert_equal users(:apiu).lists.count, JSON.parse(resp.body)['lists']['count']
      end

      test "test search list action searchlists" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:lists=>{:name=>['four']}}
        resp = get :searchlists,data_params
        assert_response 200
        assert_equal 1, JSON.parse(resp.body)['lists'][0]['count']
        assert JSON.parse(resp.body)['notFoundName'].blank?
      end

      test "not found" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:lists=>{:name=>['fourfgsdf']}}
        resp = get :searchlists,data_params
        assert_response 422
      end
    end
  end
end

