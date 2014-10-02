json.array!(@single_messages) do |single_message|
  json.extract! single_message, :id, :message, :number
  json.url single_message_url(single_message, format: :json)
end
