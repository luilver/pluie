json.array!(@group_messages) do |group_message|
  json.extract! group_message, :id, :group_id, :message
  json.url group_message_url(group_message, format: :json)
end
