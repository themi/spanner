module AwsUtils
  class Organisations < Base

    def initialize(**options)
      initialize_client(Aws::Organizations::Client, options)
    end

    def create_account(account_name, account_email)
      @response = client.create_account({
        email: account_email, 
        account_name: account_name, 
        iam_user_access_to_billing: "ALLOW" # (still need to: create login and assign appropriate policy)
      })
      puts response.to_h
      puts ""

      new_id = response.create_account_status.id

      puts "standby..."
      sleep 4 # apparently there is no wait command!

      @response = client.describe_create_account_status({
        create_account_request_id: new_id, 
      })
      puts response.create_account_status.to_h
      puts ""
    end

    def list_accounts
      accounts = []
      @response = client.list_accounts
      list_populate(accounts)
      while response.next_token
        @response = client.list_accounts({ next_token: response.next_token })
        list_populate(accounts)
      end
      accounts.map { |acct| puts "#{acct.name}: #{acct.email} (#{acct.id})" }
    end

    private

      def list_populate(accounts)
        @response.accounts.map { |item| accounts << item }
      end
  end
end
