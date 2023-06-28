module ACube
  module Endpoint
    class Invoices < ItApiBase
      def create(invoice)
        response = connection.post do |req|
          req.url "/invoices"
          req.body = invoice
        end

        if response.success?
          return JSON.parse(response.body).uuid
        else
          raise "Invoice creation failed"
        end
      end

      def download(uuid)
        response = connection.get do |req|
          req.url "/invoices/#{uuid}"
          req.headers['Content-Type'] = 'application/pdf'
          req.headers['X-PrintTheme'] = 'standard'
        end

        if response.success?
          return StringIO.new(response.body)
        else
          raise "Invoice download failed"
        end
      end
    end
  end
end