require "faraday"
require 'json'
require 'ostruct'
require 'uri'

module Helpdesk
  class Client
    attr_reader :connection, :response

    def initialize(logger=false)
      @connection = Faraday.new(url: Helpdesk.config.zendesk_url) do |conn|
        conn.basic_auth "#{Helpdesk.config.zendesk_username}/token", Helpdesk.config.zendesk_api_token
        conn.request  :url_encoded
        conn.response :logger if logger
        conn.adapter  Faraday.default_adapter
      end
    end

    def organisations
      @response = connection.get do |req|
        req.url "/api/v2/organizations.json"
        req.headers['Content-Type'] = 'application/json'
      end
      response.body
    end

    def users_for(org_id)
      @response = connection.get do |req|
        req.url "/api/v2/organizations/#{org_id}/users.json"
        req.headers['Content-Type'] = 'application/json'
      end
      response.body
    end

    def open_tickets_for(org_id)
      @response = connection.get do |req|
        req.url "/api/v2/search.json?query=#{open_ticket_search_string_for(org_id)}"
        req.headers['Content-Type'] = 'application/json'
      end
      response.body
    end

    def success?
      response.success?
    end

    def body
      response.body
    end

    def error_message
      response.header + "\n" + response.body
    end

    # -----
    private
    # -----

      def open_ticket_search_string_for(id)
        URI.encode "type:ticket status:open status:pending organization:#{id}"
      end
  end
end
