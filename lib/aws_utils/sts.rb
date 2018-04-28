module AwsUtils
  class Sts < Base

    def initialize(**options)
      initialize_client(Aws::STS::Client, options)
    end

    def credentials_for(account_id, role_name, external_id)
      @response = client.assume_role({
        duration_seconds: 900, 
        external_id: external_id, 
        role_arn: "arn:aws:iam::#{account_id}:role/#{role_name}", 
        role_session_name: "SetupBillingForAccount#{account_id}", 
      })

      response
    end

  end
end
