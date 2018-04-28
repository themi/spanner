module AwsUtils
  class Base
    attr_reader :client, :response

    private

      def initialize_client(klass, options)
        @client = if !options[:profile].nil?
          creds = Aws::SharedCredentials.new(profile_name: options[:profile])
          klass.new(credentials: creds, region: 'us-east-1')
        elsif !options[:credentials].nil?
          klass.new(credentials: options[:credentials], region: 'us-east-1')
        else
          klass.new(region: 'us-east-1')
        end

        if !options[:region].nil?
          Aws.config.update({region: options[:region]})
        end
      end
  end
end
