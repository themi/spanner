module Spanner
  class Resources
    class << self
      def create_workbench_from_asg(profile_name, environment, role, region, type, size, clone)
        profile = Authorisation::Profile.new(profile_name, region: region)
        asg = AwsUtils::Autoscaling.new(profile.credentials)
        puts_aws_results asg.create_workbench("welllettered-production-web")
      end
    end
  end
end
