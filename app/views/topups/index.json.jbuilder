json.array!(@topups) do |topup|
  json.extract! topup, :id, :number, :amount
  json.url topup_url(topup, format: :json)
end
