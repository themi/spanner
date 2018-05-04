module AwsUtils
  class Iam < Base

    def initialize(**options)
      initialize_client(Aws::IAM::Client, options)
    end

    def create_user(iam_user_name, account_name)
      @response = @client.create_user({ user_name: iam_user_name })
      puts @response.to_h

      user = @client.wait_until(:user_exists, user_name: iam_user_name)

      @response = client.create_access_key({ user_name: iam_user_name })
      put_response @response
      puts ""

      key_pair = @response.access_key
      put_data "[#{account_name}-init]"
      put_data "aws_access_key_id=#{key_pair.access_key_id}"
      put_data "aws_secret_access_key=#{key_pair.secret_access_key}"
      puts ""

      @response = client.attach_user_policy({
        policy_arn: "arn:aws:iam::aws:policy/AdministratorAccess", 
        user_name: iam_user_name 
      })
    end

    def undo_user(iam_user_name, key_id, policy_arn)
      @response = client.delete_access_key({
        access_key_id: key_id, 
        user_name: iam_user_name, 
      })

      resp = client.detach_user_policy({
        user_name: iam_user_name, 
        policy_arn: "arn:aws:iam::aws:policy/AdministratorAccess"
      })

      @response = client.delete_user({ user_name: iam_user_name })
    end


  end
end
