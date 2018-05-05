require 'inifile'

module Authorisation
  class Profile
    attr_accessor :profile_name, :region

    def initialize(profile_name, **vars)
      @profile_name = profile_name
      @region         = vars[:region] || 'ap-southeast-2'
      @key            = vars[:aws_access_key_id]
      @secret         = vars[:aws_secret_access_key]
      @session_token  = vars[:aws_session_token]
    end

    # instance methods
    # ----------------

    def credentials
      creds = if is_local?
        if profile_name == "default"
          {}
        else
          { profile: profile_name }
        end
      else
        { credentials: remote_credentials(profile_name) }
      end
      creds[:region] = region unless region.nil?
      creds
    end

    def is_local?
      !search(@@local_profiles).nil?
    end

    def is_remote?
      !search(@@remote_profiles).nil?
    end


    # private instance methods
    # ------------------------

    def remote_credentials
      create_session if !@session_token
      Aws::Credentials.new(@key, @secret, @session_token)
    end

    def search(array)
      array.select { |a|  a == profile_name }.first
    end

    def create_session
      sessions = Authorisation::Locksmith.fetch("#{profile_name}/aws_sessions/new")
      @region         = sessions['region'] || region
      @key            = sessions['access_key_id']
      @secret         = sessions['secret_access_key']
      @session_token  = sessions['session_token']
    end

    private :search, :remote_credentials, :create_session

    class << self
      def all
        { local: @@local_profiles, remote: @@remote_profiles }
      end

      def list(type)
        (type == :local ?  @@local_profiles : @@remote_profiles)
      end

      def display_profiles
        puts_info "Profiles"
        puts_info "  Local:"
        display_list(@@local_profiles, "    ")
        puts_info "  Remote:"
        display_list(@@remote_profiles, "    ", @@local_profiles.length+1)
        puts ""
      end

      def display_list(list, prefix="", index_start=1)
        if list.any?
          list.each_with_index.map { |p, i| puts_data (prefix + "#{i + index_start}. #{p}") }
        else
          puts_data (prefix+"none!")
        end
      end

      def gather_local_profiles
        profiles = []
        creds_file_path = File.expand_path(Authorisation.config.aws_local_credentials_path)
        if File.exist?(creds_file_path)
          ::IniFile.load(creds_file_path).each_section do |section|
            profiles << section
          end
        end
        profiles.flatten.compact.uniq.sort
      end

      def gather_remote_profiles
        profiles = []
        list = Authorisation::Locksmith.fetch("/profiles")
        list.each do |p|
          profiles << p['slug']
        end
        profiles
      end
    end

    @@local_profiles = self.gather_local_profiles
    @@remote_profiles = self.gather_remote_profiles
  end
end
