require 'faraday'

module ACube
  module Endpoint
    class ItApiBase
      class UnauthorizedError < StandardError; end
      
      attr_reader :connection

      def initialize
        @connection = Faraday.new(
          url: ACube.invoice_endpoint,
          headers: {
            'Content-Type' => 'application/xml',
            'X-SendAsync' => 'true'
          }
        ) do |conn|
          conn.request :authorization, 'Bearer', -> { ACube::Endpoint::Auth.new.token! }
        end
      end
    end
  end
end