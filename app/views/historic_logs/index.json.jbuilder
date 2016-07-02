json.array!(@historic_logs) do |historic_log|
  json.extract! historic_log, :id, :action_name, :controller_name, :user_id
  json.url historic_log_url(historic_log, format: :json)
end
