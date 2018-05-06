module Spanner
  class Console < Thor
    include Thor::Actions

    def initialize(*args)
      super
    end

    desc "profiles", "List all AWS profiles"
    def profiles
      Authorisation::Profile.display_profiles
    end

    desc "describe PROFILE [--environment=ENVIRONMENT]", "Describe the stack's resources"
    method_option :environment, aliases: "-e", banner: "ENVIRONMENT", desc: "Stack environment eg. staging, production etc"
    method_option :region, banner: "REGION", aliases: "-R", desc: "AWS Region eg. us-east-1, etc"
    def describe(profile)
      environment = check_for_default(:environment)
      region = check_for_default(:region)
      Resources.describe_stack(profile, environment, region)
    end

    desc "workbench PROFILE [--environment=ENVIRONMENT] [--role=ROLE] [--size=SIZE] [--type=TYPE] [--clone|--no-clone]", "Create an EC2 resource from a pre-baked AMI for a specific ASG"
    method_option :environment, aliases: "-e", banner: "ENVIRONMENT", desc: "Stack environment eg. staging, production etc"
    method_option :role, banner: "ROLE", aliases: "-r", desc: "ASG role eg. web, worker, etc"
    method_option :region, banner: "REGION", aliases: "-R", desc: "AWS Region eg. us-east-1, etc"
    method_option :size, banner: "VOLUME_SIZE", aliases: "-s", desc: "Volume Size in Gb"
    method_option :type, banner: "INSTANCE_TYPE", aliases: "-t", desc: "AWS Instance Type eg. t2.medium, m4.xlarge, etc"
    method_option :clone, default: true, type: :boolean, desc: "Clone workbench from the ASG's AMI"
    def workbench(profile)
      Resources.create_workbench_from_asg(
        profile, 
        check_for_default(:environment), check_for_default(:role), check_for_default(:region), 
        options[:type], options[:size], options[:clone]
      )
    end

    private

      def check_for_default(arg)
        if options[arg.to_sym].nil?
          Spanner.config.send("default_#{arg.to_s}")
        else
          options[arg.to_sym]
        end
      end

  end
end
