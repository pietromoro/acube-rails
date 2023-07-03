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
            'Authorization' => 'Bearer ' + ACube::Endpoint::Auth.new.token!,
            'X-SendAsync' => 'true'
          }
        )
      end
    end
  end
end