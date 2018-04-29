module AwsAccounts
  class Console < Thor
    include Thor::Actions

    def initialize(*args)
      super
    end

    desc "create NAME [EMAIL]", "Create a new billing AWS Account within current organisation root account"
    def create(account_name, account_email=nil)
      account_name = preset_name(account_name)
      account_email = set_email_address(account_name) if account_email.nil?

      orgs = AwsUtils::Organisations.new(profile: AwsAccounts.config.account_admin_profile)
      orgs.create(account_name, account_email)
    end

    desc "list_all", "List all the billing AWS Accounts within current organisation root account"
    def list_all
      orgs = AwsUtils::Organisations.new(profile: AwsAccounts.config.account_admin_profile)
      orgs.list_all
    end

    desc "setup_onbording_user ACCOUNT_ID", "Initialize the new billing AWS Account"
    def setup_onbording_user(account_id)
      sts = AwsUtils::Sts.new(profile: AwsAccounts.config.account_admin_profile)

      role_creds = sts.credentials_for(account_id, AwsAccounts.config.account_access_role, AwsAccounts.config.sts_external_id)
      iam = AwsUtils::Iam.new(credentials: role_creds)

      output = iam.add_onbording_ic(AwsAccounts.config.onboarding_ic, account_id)
    end

    desc "undo_user ACCOUNT_ID, USERNAME, AWS_ACCESS_KEY_ID", "Rollback/Delete the user created with setup_onbording_user so you can start again"
    def undo_user(account_id, username, key_id)
      sts = AwsUtils::Sts.new(profile: AwsAccounts.config.account_admin_profile)

      role_creds = sts.credentials_for(account_id, AwsAccounts.config.account_access_role, AwsAccounts.config.sts_external_id)
      iam = AwsUtils::Iam.new(credentials: role_creds)

      iam.undo_user(username, key_id)
    end

    private

      def set_email_address(account_name)
        AwsAccounts.config.email_template.sub("%{ACCOUNT_NAME}", account_name.downcase.gsub(/[\s|_]/, "-"))
      end

      def preset_name(account_name)
         AwsAccounts.config.account_name_template.sub("%{ACCOUNT_NAME}", account_name)
      end
  end
end