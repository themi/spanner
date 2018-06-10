module Helpdesk
  class Printer
    attr_accessor :json_data
    def initialize(json_data)
      @json_data = json_data
    end

    def users
      users = json_to_object(json_data)
      users.users.each do |user|
        puts_data user.email
        puts_info "  ID: #{user.id}"
        puts_info "  name: #{user.name}"
        puts_info "  verified: #{user.verified}"
      end
    end

    def organisations
      orgs = json_to_object(json_data)
      orgs.organizations.each do |org|
        puts_data org.name
        puts_info "  ID: #{org.id}"
        puts_info "  OpsCare: #{org.organization_fields.service_opscare}"
        puts_info "  CodeCare dev: #{org.organization_fields.code_care_developer}"
      end
    end

    def tickets
      results = json_to_object(json_data)
      results.results.each do |ticket|
        puts_data ticket.subject
        puts_info "  ID: #{ticket.id}"
        puts_info "  status: #{ticket.status}"
        puts_info "  Requestor: #{ticket.requester_id}"
        puts_info "  Assignee: #{ticket.assignee_id}"
      end
    end

    private

      def json_to_object(json_data=nil)
        JSON.parse(json_data, object_class: OpenStruct)
      end
  end
end
