Spanner.configure do |c|
  c.default_environment = "staging"
  c.default_role        = "web"
  c.default_region      = "ap-southeast-2"
  c.cache_folder        = "cache"
end
