json.array!(@debits) do |debit|
  json.extract! debit, :id, :user_id, :balance
  json.url debit_url(debit, format: :json)
end
