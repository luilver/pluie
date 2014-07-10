json.array!(@gateways) do |gateway|
  json.extract! gateway, :id, :name, :price
  json.url gateway_url(gateway, format: :json)
end
