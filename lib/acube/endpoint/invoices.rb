module ACube
  module Endpoint
    class Invoices < ItApiBase
      def create(invoice_xml)
        response = connection.post do |req|
          req.url "/invoices"
          req.body = invoice_xml
        end

        if response.success?
          return JSON.parse(response.body)["uuid"]
        else
          raise "Invoice creation failed: #{response.body} -- #{response.inspect} "
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
          raise "Invoice download failed: #{response.body} -- #{response.inspect}"
        end
      end
    end
  end
end