require 'stringio'

module ACube
  class Invoicer
    attr_accessor :supplier, :customer, :invoice
    attr_accessor :header, :document

    def self.from(supplier:, customer:, invoice:, format: :FPR12)
      ACube::InvoiceRecord.formats.include?(format) || raise "Format #{format} not supported"
      new(supplier, customer, invoice, format)
    end

    def create_invoice(name)
      progressive_val = ACube::InvoiceRecord.connection.execute("SELECT nextval('acube_invoice_records_progressive_seq') FROM acube_invoice_records_progressive_seq").first["nextval"]
      progressive_string = ACube.progressive_string.call(progressive_val)
      document.fill_with(transmission_format: :FPR12, progressive: progressive_string)

      invoice_record = ACube::InvoiceRecord.create!(
        record: invoice_base_record,
        name: name,
        format: @format,
        kind: invoice.document_kind,
        status: :created,
        progressive: progressive_string,
        xml_body: document.to_xml,
      )

      uuid = ACube::Endpoint::Invoices.new.create(document)
      invoice_record.update_column(:webhook_uuid, uuid)
    end

    def udate_invoice_attributes(invoice_id, json_body, pdf_url)
      invoice_record = ACube::InvoiceRecord.find_by(webhook_uuid: invoice_id)
      invoice_record.update_column(:json_body, json_body)
      
      downloaded_pdf = ACube::Endpoint::Invoices.new.download(invoice_id)
      downloaded_io = StringIO.new(downloaded_pdf.body)
      invoice_record.pdf.attach(io: downloaded_io, filename: "invoice.pdf")
      invoice_record.update_column(:status, :downloaded)
    end

    def update_invoice_status(invoice_id)
      invoice_record = ACube::InvoiceRecord.find_by(webhook_uuid: invoice_id)
      invoice_record.update_column(:status, notification["status"])
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
