module Helpdesk
  class Console < Thor
    include Thor::Actions

    def initialize(*args)
      super
    end

    def self.source_root
      File.dirname(__FILE__)
    end

    desc "organisations [--logger]", "List all organisations for reinteractive's Zendesk"
    method_option :logger, default: false, type: :boolean, desc: "output logging to stdout"
    def organisations
      retrieve_organisations(options[:logger])
    end

    desc "contacts ORGANISATION_ID [--logger]", "List all users for the specified organisation"
    method_option :logger, default: false, type: :boolean, desc: "output logging to stdout"
    def contacts(organisation_id)
      retrieve_users_for(organisation_id, options[:logger])
    end

    desc "tickets ORGANISATION_ID [--logger]", "List all users for the specified organisation"
    method_option :logger, default: false, type: :boolean, desc: "output logging to stdout"
    def tickets(organisation_id)
      retrieve_tickets_for(organisation_id, options[:logger])
    end

    private

      def json_to_object(json_data=nil)
        JSON.parse(json_data, object_class: OpenStruct)
      end

      def quick_display_users(json_data)
        users = json_to_object(json_data)
        users.users.each do |user|
          puts_data user.email
          puts_info "  ID: #{user.id}"
          puts_info "  name: #{user.name}"
          puts_info "  verified: #{user.verified}"
        end
      end

      def quick_display_organisations(json_data)
        orgs = json_to_object(json_data)
        orgs.organizations.each do |org|
          puts_data org.name
          puts_info "  ID: #{org.id}"
          puts_info "  OpsCare: #{org.organization_fields.service_opscare}"
          puts_info "  CodeCare dev: #{org.organization_fields.code_care_developer}"
        end
      end

      def quick_display_tickets(json_data)
        orgs = json_to_object(json_data)
        orgs.results.each do |ticket|
          puts_data ticket.subject
          puts_info "  ID: #{ticket.id}"
          puts_info "  status: #{ticket.status}"
          puts_info "  Requestor: #{ticket.requester_id}"
          puts_info "  Assignee: #{ticket.assignee_id}"
        end
      end

      def file_expired?(filename)
        (File.mtime(filename) + Helpdesk.config.cache_expire_time) > Time.now
      end

      def read_cached(json_file)
        filespec = File.join(Helpdesk.config.cache_folder, json_file)
        if File.exist?(filespec) && !file_expired?(filespec)
          File.read(filespec)
        else
          nil
        end
      end

      def save_cached(json_file, json_data)
        filespec = File.join(Helpdesk.config.cache_folder, json_file)
        File.open(filespec, 'w+') { |file| file.write(json_data) }
      end

      def retrieve_organisations(logger)
        unless (json_data = read_cached("organisations.json"))
          client = Helpdesk::Client.new(logger)
          client.organisations
          if client.success?
            json_data = client.body
          else
            puts_alert client.error_message
          end
        end
        if json_data
          save_cached("organisations.json", json_data)
          quick_display_organisations(json_data)
        end
      end

      def retrieve_users_for(organisation_id, logger)
        unless (json_data = read_cached("users_for_#{organisation_id}.json"))
          client = Helpdesk::Client.new(logger)
          client.users_for(organisation_id)
          if client.success?
            json_data = client.body
          else
            puts_alert client.error_message
          end
        end
        if json_data
          save_cached("users_for_#{organisation_id}.json", json_data)
          quick_display_users(json_data)
        end
      end

      def retrieve_tickets_for(organisation_id, logger)
        unless (json_data = read_cached("tickets_for_#{organisation_id}.json"))
          client = Helpdesk::Client.new(logger)
          client.open_tickets_for(organisation_id)
          if client.success?
            json_data = client.body
          else
            puts_alert client.error_message
          end
        end
        if json_data
          save_cached("tickets_for_#{organisation_id}.json", json_data)
          quick_display_tickets(json_data)
        end
      end

  end
end
