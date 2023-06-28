require 'faraday'

module ACube
  module Endpoint
    class CommonBase
      attr_reader :connection

      def initialize
        @connection = Faraday.new(
          url: ACube.common_endpoint,
          headers: {'Content-Type' => 'application/json'}
        )
      end
    end
  end
end