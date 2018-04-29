require "aws_utils"
require "aws_billing/config"
require "initializers/aws_billing"

module AwsBilling
  class Console < Thor
    include Thor::Actions

    def initialize(*args)
      super
    end

    desc "create_account NAME [EMAIL]", "Create a new billing AWS Account within current organisation root account"
    def create_account(account_name, account_email=nil)
      account_name = preset_name(account_name)
      account_email = set_email_address(account_name) if account_email.nil?

      orgs = AwsUtils::Organisations.new(profile: AwsBilling.config.account_admin_profile)
      orgs.create_account(account_name, account_email)
    end

    desc "list_accounts", "List all the billing AWS Accounts within current organisation root account"
    def list_accounts
      orgs = AwsUtils::Organisations.new(profile: AwsBilling.config.account_admin_profile)
      orgs.list_accounts
    end

    desc "setup_account ACCOUNT_ID", "Initialize the new billing AWS Account"
    def setup_account(account_id)
      sts = AwsUtils::Sts.new(profile: AwsBilling.config.account_admin_profile)

      role_creds = sts.credentials_for(account_id, AwsBilling.config.account_access_role, AwsBilling.config.sts_external_id)
      iam = AwsUtils::Iam.new(credentials: role_creds)

      output = iam.add_onbording_ic(AwsBilling.config.onboarding_ic, account_id)
    end

    desc "undo_user ACCOUNT_ID, USERNAME, AWS_ACCESS_KEY_ID", "Rollback/Delete the user created with setup_account so you can start again"
    def undo_user(account_id, username, key_id)
      sts = AwsUtils::Sts.new(profile: AwsBilling.config.account_admin_profile)

      role_creds = sts.credentials_for(account_id, AwsBilling.config.account_access_role, AwsBilling.config.sts_external_id)
      iam = AwsUtils::Iam.new(credentials: role_creds)

      iam.undo_user(username, key_id)
    end

    private

      def set_email_address(account_name)
        AwsBilling.config.email_template.sub("%{ACCOUNT_NAME}", account_name.downcase.gsub(/[\s|_]/, "-"))
      end

      def preset_name(account_name)
         AwsBilling.config.account_name_template.sub("%{ACCOUNT_NAME}", account_name)
      end
  end
end
