module Helpdesk
  class Resource
    class << self
      def organisations(logger)
        unless (json_data = Helpdesk::Storage.new("organisations.json").read)
          client = Helpdesk::Client.new(logger)
          client.organisations
          if client.success?
            json_data = client.body
          else
            puts_alert client.error_message
          end
        end
        if json_data
          Helpdesk::Storage.new("organisations.json").save(json_data)
          Helpdesk::Printer.new(json_data).organisations
        end
      end

      def users_for(organisation_id, logger)
        unless (json_data = Helpdesk::Storage.new("users_for_#{organisation_id}.json").read)
          client = Helpdesk::Client.new(logger)
          client.users_for(organisation_id)
          if client.success?
            json_data = client.body
          else
            puts_alert client.error_message
          end
        end
        if json_data
          Helpdesk::Storage.new("users_for_#{organisation_id}.json").save(json_data)
          Helpdesk::Printer.new(json_data).users
        end
      end

      def tickets_for(organisation_id, logger)
        unless (json_data = Helpdesk::Storage.new("tickets_for_#{organisation_id}.json").read)
          client = Helpdesk::Client.new(logger)
          client.open_tickets_for(organisation_id)
          if client.success?
            json_data = client.body
          else
            puts_alert client.error_message
          end
        end
        if json_data
          Helpdesk::Storage.new("tickets_for_#{organisation_id}.json").save(json_data)
          Helpdesk::Printer.new(json_data).tickets
        end
      end
    end
  end
end
