require 'yaml'
require 'fileutils'
require 'time'
require "aws_utils"
require "authorisation/config"
require "initializers/authorisation"
require "authorisation/locksmith"
require "authorisation/profile"

module Authorisation
  class << self
    attr_accessor :cache_path

    def flush
      FileUtils.rm_rf(base_path)
    end

    def find(profile_name, region)
      file_path = File.join(base_path, "#{profile_name}.yaml")
      data = read_data(file_path)
      if data
        Authorisation::Profile.new(profile_name, data)
      else
        Authorisation::Profile.new(profile_name, region: region)
      end
    end

    def cache(profile)
      file_path = File.join(base_path, "#{profile.profile_name}.yaml")
      save_data(profile.to_hash, file_path)
    end

    private

      def base_path
        File.join(cache_path, "authorisations")
      end

      def save_data(data, file_path)
        unless File.directory?(File.dirname(file_path))
          FileUtils.mkdir_p(File.dirname(file_path))
        end
        File.open(file_path, 'w+') { |file| file.write(data.to_yaml) }
      end

      def read_data(file_path)
        if File.exist?(file_path)
          YAML::load_file(file_path)
        end
      end
  end
end

Authorisation.cache_path = File.join(File.expand_path("~/.cache"), "spanner")
