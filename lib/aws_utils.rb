require 'yaml'
require 'fileutils'
require 'time'
require "aws-sdk"
require "aws_utils/base"
require "aws_utils/organisations"
require "aws_utils/sts"
require "aws_utils/iam"
require "aws_utils/autoscaling"

module AwsUtils
  class << self
    attr_accessor :cache_path

    def flush(profile_name=nil)
      if profile_name
        FileUtils.rm_rf(File.join(base_path, profile_name))
      else
        FileUtils.rm_rf(File.join(base_path))
      end
    end

    def find(profile_name, resource_name)
      read_data(file_path(profile_name, resource_name))
    end

    def cache(profile_name, resource_name, data_hash)
      save_data(data_hash, file_path(profile_name, resource_name))
    end

    private

      def file_path
        File.join(base_path, profile_name, "#{resource_name}.yaml")
      end

      def base_path
        File.join(cache_path, "stacks")
      end

      def save_data(data_hash, file_path)
        unless File.directory?(File.dirname(file_path))
          FileUtils.mkdir_p(File.dirname(file_path))
        end
        File.open(file_path, 'w+') { |file| file.write(data_hash.to_yaml) }
      end

      def read_data(file_path)
        if File.exist?(file_path)
          YAML::load_file(file_path)
        end
      end
  end
end

AwsUtils.cache_path = File.join(File.expand_path("~/.cache"), "spanner")

