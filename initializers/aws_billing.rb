AwsBilling.configure do |c|
  c.admin_profile         = "organisation-admin"
  c.account_admin_profile = "account-admin"
  c.account_access_role   = "OrganizationAccountAccessRole"
  c.email_template        = "support+%{ACCOUNT_NAME}@reinteractive.net"
  c.account_name_template = "OpsCare %{ACCOUNT_NAME}"
  c.sts_external_id       = "reinteractive-OpsCare"
  c.onboarding_ic         = "tim@reinteractive.net"
end
