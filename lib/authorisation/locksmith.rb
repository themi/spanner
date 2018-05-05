module Authorisation
  class Locksmith
    class << self
      def fetch(endpoint, params = {}, verbose=false)
        puts "Fetching Locksmith data".blue if verbose

        uri = URI(File.join(Authorisation.config.locksmith_url, endpoint))
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')

        begin
          http.start do |h|
            request = Net::HTTP::Get.new uri
            request['User-Email']      = Authorisation.config.locksmith_email
            request['Locksmith-Token'] = Authorisation.config.locksmith_token

            h.request request do |response|
              if response.is_a? Net::HTTPSuccess
                @resp = response.body
              else
                @resp = "{}"
                puts "Locksmith connection has failed.".red if verbose
                puts "Response status was #{response.code} - #{response.message}".red if verbose
                if response.code == '401'
                  puts "    Are your Locksmith email and token properly set in your config file ?".magenta if verbose
                end
              end
            end
          end
        rescue => e
          case e
          when Errno::ECONNREFUSED
            @resp = "{}"
            puts "Locksmith connection has failed.".red if verbose
          else
            raise e
          end
        end

        @resp = JSON.parse(@resp)
        @resp
      end
    end
  end
end
# Thanks to Raphael Campardou for this class
