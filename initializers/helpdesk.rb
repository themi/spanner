Helpdesk.configure do |c|
  c.zendesk_url = "https://reinteractive.zendesk.com"
  c.zendesk_username = "tim@reinteractive.net"
  c.zendesk_api_token = "lQ6oqQCZa0gN9toNopKKCMeLrDUf7HbFHdQQQNN2"
  c.zendesk_user_id = 294758444
  c.cache_expire_time = 3600
  c.cache_folder = File.expand_path("cache")
end
