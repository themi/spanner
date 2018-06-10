Helpdesk.configure do |c|
  c.zendesk_url = "https://reinteractive.zendesk.com"
  c.zendesk_username = ENV["ZENDESK_LOGIN"]
  c.zendesk_api_token = ENV["ZENDESK_API_TOKEN"]
  c.cache_expire_time = 3600
  c.cache_folder = File.expand_path("cache/helpdesk")
end
