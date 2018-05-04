module AwsUtils
  class Organisations < Base

    def initialize(**options)
      initialize_client(Aws::Organizations::Client, options)
    end

    def create(account_name, account_email)
      @response = client.create_account({
        email: account_email, 
        account_name: account_name, 
        iam_user_access_to_billing: "ALLOW" # (still need to: create login and assign appropriate policy)
      })
      puts_response response
      puts ""

      new_id = response.create_account_status.id

      puts_info "standby..."
      puts ""
      sleep 4 # apparently there is no wait command!

      @response = client.describe_create_account_status({
        create_account_request_id: new_id, 
      })
      puts_response response.create_account_status
      puts ""
    end

    def list_all
      accounts = []
      @response = client.list_accounts
      list_populate(accounts)
      while response.next_token
        @response = client.list_accounts({ next_token: response.next_token })
        list_populate(accounts)
      end
      accounts.sort_by { |a| a[:status]+a[:name] }.map { |acct| puts "##{acct[:id]} [#{acct[:status]}]".blue.bold + " #{acct[:name]}".cyan + " (#{acct[:email]})".blue.bold }
    end

    private

      def list_populate(container)
        @response.accounts.map { |item| container << item.to_h }
      end
  end
end
