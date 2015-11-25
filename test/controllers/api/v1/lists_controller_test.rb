require 'test_helper'
require 'json'

module Api
  module V1
    class ListsControllerTest < ActionController::TestCase


      def setup
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @request.headers['Accept'] = Mime::JSON
        @request.headers['Content-Type'] = Mime::JSON.to_s
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
        resp = get :show, {:id=>100}
        assert_response 200,resp.body
        assert_equal 'six', JSON.parse(resp.body)['list']['name']
      end

      test "action show in api list id wrong" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        resp =get :show, {:id=>14}
        assert_response 422,resp.body
      end

      test "create list via api" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'

        data_params={:list=>{:name=>'listApiTest',:numbers=>["5352503135"]}}
        assert_difference('List.count') do
          post :create ,data_params
        end
        assert_response 201
        assert_equal "listApiTest", List.find_by_name(:listApiTest).name
        assert_equal 1, List.find_by_name(:listApiTest).receivers.count
      end

      test "create list and verify numbers inserted" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        numbers=[]
        count_number=0
         5358850001.upto(5358850210) do |i|
          numbers << i
           count_number=count_number+1
         end
        data_params={:list=>{:name=>'listApiTest',:numbers=>numbers}}
        resp = post :create , data_params

        assert_equal count_number, List.find_by_name(:listApiTest).receivers.count
        data_response='List was successfully created'
        assert_equal data_response , JSON.parse(resp.body)['message']
        numbers << '5331245617'
        data_params={:list=>{:name=>'listApiTest',:numbers=>numbers}}
        resp = post :create , data_params
        assert_equal count_number, List.find_by_name(:listApiTest).receivers.count
        assert_response 422
      end

      test "name is blank" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'

        resp = post :create, {:name=>"", :numbers=>["5356789014"]}
        assert_response 404
      end

      test "name is in use" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'

        data_params={:list=>{:name=>'six',:numbers=>["5352503135"]}}
        resp = post :create, data_params
        assert_response 422
      end

      test "count number list 0" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'

        data_params={:list=>{:name=>'listApiTest',:numbers=>["5342503135"]}}
        post :create ,data_params
        assert_response 201
        assert_equal 0, users(:apiu).lists.find_by_name(:listApiTest).receivers.count
      end

      test "list with numbers empty" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'

        data_params={:list=>{:name=>'listApiTest',:numbers=>[]}}
        post :create, data_params
        assert_response 422
      end

      test "update name blank" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:list=>{:name=>'',:numbers=>[535148368]}}
        put :update , data_params
        assert_response 404
      end

      test "update ok" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:list=>{:name=>'four',:numbers=>[5351483687],:remove=>false}}
        resp=put :update , data_params
        assert_response 200, resp.body
        assert_equal 2, users(:apiu).lists.find_by_name(:four).receivers.count
      end

      test "invalid name update" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:list=>{:name=>'listApi',:numbers=>[5351483687],:remove=>false}}
        resp=put :update , data_params
        assert_response 422
      end

      test "option remove true" do
          @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
          @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'

          numbers=[]
          count_number=0
          5358880001.upto(5358880022) do |i|
            numbers << i
            count_number=count_number+1
          end

          data_params={:list=>{:name=>'five',:numbers=>numbers,:remove=>true}}
          resp=put :update , data_params
          assert_response 200
          assert_equal 0, users(:apiu).lists.find_by_name(:five).receivers.count
      end


      test "destroy name invalid" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:list=>{:name=>'listApi'}}
        resp=delete :destroy , data_params
        assert_response 422
      end

      test "destroy name blank" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:list=>{:name=>''}}
        resp=delete :destroy , data_params
        assert_response 404
      end

      test "destroy list ok" do
        @request.headers["HTTP_EMAIL"]= 'ale5@gmail.com'
        @request.headers["HTTP_API_KEY"] = '561b7ec89b0ca61b250815b24e398ae'
        data_params={:list=>{:name=>'five'}}
        count=List.count
        delete :destroy, data_params
        assert_equal count-1, List.count
        assert_response 301
      end
    end
  end
end

