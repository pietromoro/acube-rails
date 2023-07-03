module ACube
  module Endpoint
    class Invoices < ItApiBase
      def create(invoice_xml)
        already_tried = false

        begin
          response = connection.post do |req|
            req.url "/invoices"
            req.body = invoice_xml
          end

          if response.success?
            return JSON.parse(response.body)["uuid"]
          elsif response.status == 401 && !already_tried
            raise UnauthorizedError
          else
            raise "Invoice creation failed: #{response.body} -- #{response.inspect} "
          end
        rescue UnauthorizedError
          auth = ACube::Endpoint::Auth.new
          auth.refresh_token
          already_tried = true
          retry
        end
      end

      def download(uuid)
        already_tried = false

        begin
          response = connection.get do |req|
            req.url "/invoices/#{uuid}"
            req.headers['Content-Type'] = 'application/pdf'
            req.headers['X-PrintTheme'] = ACube.invoice_print_theme || 'standard'
          end

          if response.success?
            return StringIO.new(response.body)
          elsif response.status == 401 && !already_tried
            raise UnauthorizedError
          else
            raise "Invoice download failed: #{response.body} -- #{response.inspect}"
          end
        rescue UnauthorizedError
          auth = ACube::Endpoint::Auth.new
          auth.refresh_token
          already_tried = true
          retry
        end
      end
    end
  end
end