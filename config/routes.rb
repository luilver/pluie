require 'api_constraints'

Rails.application.routes.draw do

  namespace :api, :defaults => {:format => 'json'} do
    scope :module => :v1, :constraints => ApiConstraints.new(:version => 1, :default => true) do
      get 'user/balance' => 'users#balance'
      get 'lists/searchs' => 'search_lists#index'
      match 'lists/searchs' => 'search_lists#searchlists', via: :post
      resources :bulk_messages
      resources :credits
      resources :lists
      resources :single_messages
      resources :users
    end
  end

  concern :deliverable do
    get 'deliveries' => 'action_smser/delivery_reports#message_deliveries', as: :deliveries
  end

  get 'delivery_reports/gateway_commit/:gateway' => 'action_smser/delivery_reports#gateway_commit'
  post 'delivery_reports/gateway_commit/:gateway' => 'action_smser/delivery_reports#gateway_commit'

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


  devise_for :users
  root to: "home#index"
  #
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
