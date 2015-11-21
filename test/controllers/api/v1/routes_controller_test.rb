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
        resp= get :index
        assert_response 200, resp.body
      end

      test "test the action index unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        get :index
        assert_response 401
      end

      test "test the action show id wrong" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        params_data={:id=>120}
        resp= get :show,params_data
        assert_response 422, resp.body
      end

      test "test the action show unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        params_data={:id=>26}
        resp= get :show, params_data
        assert_response 401, resp.body
      end

      test "test the action show ok" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        params_data={:id=>26}
        resp= get :show,params_data
        assert_response 200, resp.body
        assert_equal routes(:routeBulkNotCredit).name, JSON.parse(resp.body)['route']['name_route']
      end

      test "test the action by name ok" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        params_data={:route=>{:name_route=>'Gold'}}
        resp= post :by_route_name, params_data
        assert_response 200, resp.body
        assert_equal Route.where(:name=>'Gold').count, JSON.parse(resp.body)['routes'].count
      end

      test "test the action by name wrong" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        params_data={:route=>{:name_route=>'Goldxx'}}
        resp= post :by_route_name, params_data
        assert_response 422, resp.body
        params_data={:route=>{:name_route=>''}}
        resp= post :by_route_name, params_data
        assert_response 404, resp.body
      end

      test "test the action by name unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        params_data={:route=>{:name_route=>'Gold'}}
        resp= post :by_route_name, params_data
        assert_response 401, resp.body
      end

      test "test the action by email ok" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        params_data={:route=>{:email_user=>'ale5@gmail.com'}}
        resp= post :by_email_user, params_data
        assert_response 200, resp.body
        assert_equal users(:apiu).routes.count, JSON.parse(resp.body)['routes'].count
      end

      test "test the action by email wrong" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        params_data={:route=>{:email_user=>'ale5@gmsdfasdail.com'}}
        resp= post :by_email_user, params_data
        assert_response 422, resp.body
        params_data={:route=>{:email_user=>''}}
        resp= post :by_email_user, params_data
        assert_response 404, resp.body
      end

      test "test the action by email unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        params_data={:route=>{:email_user=>'ale5@gmsdfasdail.com'}}
        resp= post :by_email_user, params_data
        assert_response 401, resp.body
      end

      test "test create route" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        params_data={:route=>{:email_user=>'ale5@gmail.com',:gateway_name=>'ApiG',:price=>0.055,:name=>'routeTest'}}
        assert_difference('Route.count') do
          post :create, params_data
          assert_response 201
          assert_equal 0.055, users(:apiu).routes.find_by_name(:routeTest).price
        end
      end

      test "test create route wrong blank parameters" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        params_data={:route=>{:email_user=>'',:gateway_name=>'ApiG',:price=>0.055,:name=>'routeTest'}}
        resp=post :create, params_data
        assert_response 404
        params_data={:route=>{:email_user=>'ale5@gmail.com',:gateway_name=>'',:price=>0.055,:name=>'routeTest'}}
        resp=post :create, params_data
        assert_response 404
        params_data={:route=>{:email_user=>'ale5@gmail.com',:gateway_name=>'ApiG',:name=>'routeTest'}}
        resp=post :create, params_data
        assert_response 404
        params_data={:route=>{:email_user=>'ale5@gmail.com',:gateway_name=>'ApiG',:price=>0.055}}
        resp=post :create, params_data
        assert_response 404
      end

      test "test create route wrong gateway wrong" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        params_data={:route=>{:email_user=>'ale5@gmail.com',:gateway_name=>'ApiGGGGG',:price=>0.055,:name=>'routeTest'}}
        resp=post :create, params_data
        assert_response 422
        params_data={:route=>{:email_user=>'ale5vvvvv@gmail.com',:gateway_name=>'Api',:price=>0.055,:name=>'routeTest'}}
        resp=post :create, params_data
        assert_response 422
      end

      test "test create unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        params_data={:route=>{:email_user=>'ale5@gmail.com',:gateway_name=>'ApiG',:price=>0.055,:name=>'routeTest'}}
        resp= post :create, params_data
        assert_response 401, resp.body
      end


      test "test update route wrong blank parameters" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        params_data={:id=>21,:route=>{:email_user=>'',:gateway_name=>'ApiG',:price=>0.055,:name=>'routeTest'}}
        put :update, params_data
        assert_response 404
        params_data={:id=>21,:route=>{:email_user=>'ale5@gmail.com',:gateway_name=>'',:price=>0.055,:name=>'routeTest'}}
        put :update, params_data
        assert_response 404
        params_data={:id=>21,:route=>{:email_user=>'ale5@gmail.com',:gateway_name=>'ApiG',:name=>'routeTest'}}
        put :update, params_data
        assert_response 404
        params_data={:id=>21,:route=>{:email_user=>'ale5@gmail.com',:gateway_name=>'ApiG',:price=>0.055}}
        put :update, params_data
        assert_response 404
      end

      test "test update route ok" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        assert_not_equal users(:apiu).routes.find_by_id(21).name, 'routeTest'
        params_data={:id=>21,:route=>{:email_user=>'ale5@gmail.com',:gateway_name=>'ApiG',:price=>0.055,:name=>'routeTest'}}
        put :update, params_data
        assert_response 200
        assert_equal 'routeTest',users(:apiu).routes.find_by_id(21).name
      end

      test "test update route wrong params" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        params_data={:id=>21,:route=>{:email_user=>'aaale5@gmail.com',:gateway_name=>'ApiG',:price=>0.055,:name=>'routeTest'}}
        put :update, params_data
        assert_response 422
        params_data={:id=>21,:route=>{:email_user=>'ale5@gmail.com',:gateway_name=>'ApppiG',:price=>0.055,:name=>'routeTest'}}
        put :update, params_data
        assert_response 422
      end

      test "test update unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        params_data={:id=>21,:route=>{:email_user=>'aaale5@gmail.com',:gateway_name=>'ApiG',:price=>0.055,:name=>'routeTest'}}
        put :update, params_data
        assert_response 401
      end

      test "test destroy route" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        params_data={:id=>21}
        assert_difference 'Route.count', -1 do
          delete :destroy,params_data
          assert_response 301
        end
      end

      test "test destroy route wrong parameters" do
        @request.headers["HTTP_EMAIL"]= 'admin40@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e408a1'
        params_data={:id=>23645}
        delete :destroy, params_data
        assert_response 422
      end

      test "test destroy unauthorized" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        params_data={:id=>21,:route=>{:email_user=>'aaale5@gmail.com',:gateway_name=>'ApiG',:price=>0.055,:name=>'routeTest'}}
        delete :destroy, params_data
        assert_response 401
      end
    end
  end
end

