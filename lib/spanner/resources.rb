module Spanner
  class Resources
    class << self
      def create_workbench_from_asg(profile_name, environment, role, region, type, size, clone)
        profile = Authorisation.find(profile_name, region)
        asg = AwsUtils::Autoscaling.new(profile.credentials)
        puts_aws_results asg.create_workbench("welllettered-production-web")
      end

      def describe_stack(profile_name, environment, region)
        profile = Authorisation.find(profile_name, region)
        asg = AwsUtils::Autoscaling.new(profile.credentials)

        asg_name = [profile_name, environment, "web"].join("-")

        puts_aws_results asg.describe_asg(asg_name)
      end
    end
  end
end
