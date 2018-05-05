Authorisation.configure do |c|
  c.aws_local_credentials_path = "~/.aws/credentials"
  c.locksmith_email            = ENV['_TECTONICS_MY_EMAIL']
  c.locksmith_token            = ENV['_TECTONICS_LOCKSMITH_TOKEN']
  c.locksmith_url              =  "https://locksmith.sentinel.reinteractive.net/api/v1"
end
