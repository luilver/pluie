json.array!(@observers) do |observer|
  json.extract! observer, :id, :number, :active
  json.url observer_url(observer, format: :json)
end
