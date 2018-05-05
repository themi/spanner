module AwsUtils
  class Autoscaling < Base
    attr_accessor :app_id, :environment, :role
    attr_reader :current_asg_name

    def initialize(**options)
      initialize_client(Aws::AutoScaling::Client, options)
    end

    def create_workbench(asg_name)
      init_asg_name(asg_name)
      current_austoscaling_group
      # create_instance
    end

    private
      def init_asg_name(asg_name)
        if @current_asg_name != asg_name
          @current_austoscaling_group = nil 
          @current_launch_config = nil
        end
        @current_asg_name = asg_name
      end

      def current_launch_config
        @current_launch_config ||= client.describe_launch_configurations({ launch_configuration_names: [ current_launch_config_name ] }).launch_configurations.first
      end

      def current_launch_config_name
        current_austoscaling_group.launch_configuration_name
      end

      def current_austoscaling_group
        # @current_austoscaling_group ||= client.describe_auto_scaling_groups({ auto_scaling_group_names: [current_asg_name] }).auto_scaling_groups.first
        @current_austoscaling_group ||= client.describe_auto_scaling_groups()
      end

      def create_instance
        ec2 = Aws::EC2::Resource.new

        instance = ec2.create_instances(current_launch_config.to_h).first

        ec2.client.wait_until(:instance_status_ok, {instance_ids: [instance.id]})

        instance
      end

  end
end
