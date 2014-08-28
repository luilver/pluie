json.array!(@routes) do |route|
  json.extract! route, :id, :name, :price, :user_id, :gateway_id
  json.url route_url(route, format: :json)
end
