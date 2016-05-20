json.array!(@table_routes) do |table_route|
  json.extract! table_route, :id, :name_route, :price_system, :price_cost, :country_code, :country
  json.url table_route_url(table_route, format: :json)
end
