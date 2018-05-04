module AwsUtils
  class Autoscaling < Base
    attr_accessor :app_id, :environment, :role

    def initialize(**options)
      initialize_client(Aws::AutoScaling::Client, options)
    end

    def create_workbench(asg_name)
      init_asg_name(asg_name)

      create_instance
    end

    private
      def init_asg_name(asg_name)
        if @current_asg_name != asg_name
          @austoscaling_group = nil 
          @launch_config = nil
        end
        @current_asg_name == asg_name
      end

      def launch_config
        @launch_config ||= client.describe_launch_configurations({ launch_configuration_names: [ launch_config_name ] }).launch_configurations.first
      end

      def launch_config_name
        austoscaling_group.launch_configuration_name
      end

      def austoscaling_group
        @austoscaling_group ||= client.describe_auto_scaling_groups({ auto_scaling_group_names: [current_asg_name] }).auto_scaling_groups.first
      end

      def create_instance
        ec2 = Aws::EC2::Resource.new

        instance = ec2.create_instances(launch_config.to_h).first

        ec2.client.wait_until(:instance_status_ok, {instance_ids: [instance.id]})

        instance
      end

  end
end
