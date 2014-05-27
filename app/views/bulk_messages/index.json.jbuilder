json.array!(@bulk_messages) do |bulk_message|
  json.extract! bulk_message, :id, :message, :list_id
  json.url bulk_message_url(bulk_message, format: :json)
end
