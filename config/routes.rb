require 'api_constraints'

Rails.application.routes.draw do


  resources :historic_logs
  post 'historic_logs/names' =>'historic_logs#names'

  resources :roles

  resources :table_routes

  get "join_send/index"
  post "join_send/create"
  get "join_send/new"
  get "join_send/show"
  post "home/mask_user" => "home#mask_user"
  get "home/mask_out" => "home#mask_out"

  namespace :api, :defaults => {:format => 'json'} do
    scope :module => :v1, :constraints => ApiConstraints.new(:version => 1, :default => true) do
      get 'user/balance' => 'users#balance'
      match 'user/balance' => 'users#balance', via: :post
      get 'lists/searchs' => 'search_lists#index'
      match 'lists/searchs' => 'search_lists#searchlists', via: :post
      match 'users/create_user_api' => 'users#create_user_api', via: :post
      match 'delivery_reports/show' => 'delivery_reports#show', via: :post

      ######resources lists
      match 'lists' => 'lists#index', via: :get
      match  'lists/:id' => 'lists#show', via: :get
      match  'lists'   => 'lists#create', via: :post
      match  'lists'   => 'lists#update', via: :put
      match  'lists'   => 'lists#destroy', via: :delete


      resources :bulk_messages
      match 'credits/email'=> 'credits#by_name_email', via: :post
      resources :credits
      resources :single_messages
      match 'users' => 'users#update', via: :put
      match 'users' => 'users#destroy', via: :delete
      resources :users

      devise_scope :user do
        match '/sessions' => 'sessions#create', :via => :post
        match '/sessions' => 'sessions#destroy', :via => :delete
        match  '/registrations' => 'registrations#create',   :via => :post

      end
      match 'routes/email_user'=>'routes#by_email_user', via: :post
      match 'routes/name'=>'routes#by_route_name', via: :post
      resources :routes
    end
  end

  concern :deliverable do
    get 'deliveries' => 'action_smser/delivery_reports#message_deliveries', as: :deliveries
  end

  get 'delivery_reports/gateway_commit/:gateway' => 'action_smser/delivery_reports#gateway_commit'
  post 'delivery_reports/gateway_commit/:gateway' => 'action_smser/delivery_reports#gateway_commit'

  get 'api/doc' => 'docs#api'
  get '/about' => 'pubs#about'
  get '/contact' => 'pubs#contact'
  resources :users, path: '/admin'

  authenticated :user, -> user { user.admin } do
    mount Delayed::Web::Engine, at: '/dj_web'
  end

  resources :delivery_reports,  only: [:index, :show], controller: "action_smser/delivery_reports" do
    match :summary,  via: :get, on: :collection
    match :failed_numbers, via: :get, on: :collection
  end

  resources :routes

  resources :gateways

  resources :credits

  resources :bulk_messages, concerns: :deliverable

  resources :lists

  #resources :group_messages

  resources :groups

  resources :contacts

  resources :single_messages, concerns: :deliverable

  resources :debits

  resources :observers

  #get '/:locale' => "home#index"
  #get '*path', to: redirect("/#{I18n.default_locale}/%{path}"), constraints: lambda { |req| !req.path.starts_with? "/#{I18n.default_locale}/" }
  #get '', to: redirect("/#{I18n.default_locale}/home#index")


  devise_for :users, :controllers => {:registrations => "registrations"}
  root to: "home#index"

  get "confirmation_number/confirmation" => "confirmation_number#new"
  get "confirmation_number/new_api" => "confirmation_number#new_api"
  post "confirmation_number/confirmation" => "confirmation_number#confirmation"
  get "confirmation_number/get_api" => "confirmation_number#get_api"
  get "confirmation_number/reconfirmed" => "confirmation_number#reconfirmed"
  get "confirmation_number/delete_warning" => "confirmation_number#delete_warning"

  # get 'prefix/new' => 'prefix#new'
  # post "prefix" => "prefix#create"
  # get 'prefix/:id' => 'prefix#show'
  # get 'prefixes' => 'prefix#index'
  resources :prefix

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
