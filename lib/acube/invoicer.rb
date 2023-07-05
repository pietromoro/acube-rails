module ACube
  class Invoicer
    attr_accessor :supplier, :customer, :invoice
    attr_accessor :header, :document

    def self.from(supplier:, customer:, invoice:, format: :FPR12)
      raise "Format #{format} not supported" unless ACube::InvoiceRecord.formats.include?(format)
      new(supplier, customer, invoice, format)
    end

    def create_invoice(invoice_base_record, name)
      progressive_val = ACube::InvoiceRecord.connection.execute("SELECT nextval('acube_invoice_records_progressive_seq') FROM acube_invoice_records_progressive_seq").first["nextval"]
      progressive_string = ACube.progressive_string.call(progressive_val)
      document.fill_with(transmission_format: @format, progressive: progressive_string)
      xml_body = document.to_xml

      invoice_record = ACube::InvoiceRecord.create!(
        record: invoice_base_record,
        name: name,
        format: @format,
        kind: invoice.document_kind,
        status: :created,
        progressive: progressive_string,
        xml_body: xml_body,
      )

      begin
        uuid = ACube::Endpoint::Invoices.new.create(xml_body)
        invoice_record.update_column(:webhook_uuid, uuid)
      rescue => e
        invoice_record.update_column(:status, :creation_error)
        raise e
      end
    end

    def regenerate_invoice(invoice_record_id, also_send: false)
      invoice_record = ACube::InvoiceRecord.find(invoice_record_id)
      raise "This Invoice was already sent to ACube" if invoice_record.status != "creation_error" || invoice_record.status != "rejected"

      document.fill_with(transmission_format: invoice_record.format, progressive: invoice_record.progressive)
      xml_body = document.to_xml

      invoice_record.update_columns(
        status: :created,
        xml_body: xml_body,
      )

      if also_send
        begin
          uuid = ACube::Endpoint::Invoices.new.create(xml_body)
          invoice_record.update_column(:webhook_uuid, uuid)
        rescue => e
          invoice_record.update_column(:status, :creation_error)
          raise e
        end
      end
    end

    def self.retry_invoice_sending(invoice_record_id)
      invoice_record = ACube::InvoiceRecord.find(invoice_record_id)
      raise "This Invoice was already sent to ACube" if invoice_record.status != "creation_error" || invoice_record.status != "rejected"

      begin
        uuid = ACube::Endpoint::Invoices.new.create(invoice_record.xml_body)
        invoice_record.update_column(:webhook_uuid, uuid)
      rescue => e
        invoice_record.update_column(:status, :creation_error)
        raise e
      end
    end

    def self.udate_invoice_attributes(invoice_id, json_body)
      invoice_record = ACube::InvoiceRecord.find_by(webhook_uuid: invoice_id)
      invoice_record.update_column(:json_body, json_body)
      
      begin
        downloaded_pdf = ACube::Endpoint::Invoices.new.download(invoice_record.webhook_uuid)
        downloaded_pdf.rewind
        invoice_record.pdf.attach(io: downloaded_pdf, filename: "#{invoice_record.webhook_uuid}-invoice.pdf", content_type: 'application/pdf')
        invoice_record.update_column(:status, :downloaded)
      rescue => e
        invoice_record.update_column(:status, :download_error)
        raise e
      end
    end

    def self.update_invoice_status(webhook_body)
      notification = JSON.parse(webhook_body, symbolize_names: true)
      invoice_record = ACube::InvoiceRecord.find_by(webhook_uuid: notification[:notification][:invoice_uuid])

      status = case notification[:notification][:type]
      when "MC" then :not_received
      when "AT" then :not_received
      when "RC" then :delivered
      when "NS" then :rejected
      else :notification_error
      end

      invoice_record.update_column(:status, status)
    end

  private
    def initialize(supplier, customer, invoice, format)
      @format = format

      @supplier = ACube::Schema::Header::Supplier.from(supplier)
      @customer = ACube::Schema::Header::Customer.from(customer)
      @invoice = ACube::Schema::Body.from(invoice)

      @invoice_base_record = invoice

      @header = ACube::Schema::Header::Header.new(@supplier, @customer)
      @document = ACube::Schema::Document.new(@header, @invoice)
    end
  end
end
