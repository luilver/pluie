json.array!(@contacts) do |contact|
  json.extract! contact, :id, :name, :gsm_number_id
  json.url contact_url(contact, format: :json)
end
