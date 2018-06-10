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
      Helpdesk::Resource.organisations(options[:logger])
    end

    desc "contacts ORGANISATION_ID [--logger]", "List all users for the specified organisation"
    method_option :logger, default: false, type: :boolean, desc: "output logging to stdout"
    def contacts(organisation_id)
      Helpdesk::Resource.users_for(organisation_id, options[:logger])
    end

    desc "tickets ORGANISATION_ID [--logger]", "List all users for the specified organisation"
    method_option :logger, default: false, type: :boolean, desc: "output logging to stdout"
    def tickets(organisation_id)
      Helpdesk::Resource.tickets_for(organisation_id, options[:logger])
    end

  end
end
