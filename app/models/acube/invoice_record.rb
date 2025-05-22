# frozen_string_literal: true

module ACube
  class InvoiceRecord < ACube.invoice_base_class.constantize
    self.table_name = 'acube_invoice_records'

    belongs_to :record, polymorphic: true, touch: true
    has_one_attached :pdf

    enum format: %i[ FPA12 FPR12 ]
    enum kind: %i[ TD01 TD02 TD03 TD04 TD05 TD06 TD16 TD17 TD18 TD19 TD20 TD21 TD22 TD23 TD24 TD25 TD26 TD27 TD28 ]

    enum status: { notification_error: -4, download_error: -3, creation_error: -2, error: -1, created: 0, sent: 1, downloaded: 2, not_received: 3, rejected: 4, delivered: 5 }

    def self.get_progressive(update: true)
      sql = if update
        "SELECT (nextval('acube_invoice_records_progressive_seq')) AS val FROM acube_invoice_records_progressive_seq"
      else
        "SELECT (last_value + i.inc) AS val FROM acube_invoice_records_progressive_seq, (SELECT seqincrement AS inc FROM pg_sequence WHERE seqrelid = 'acube_invoice_records_progressive_seq'::regclass::oid) AS i"
      end
      self.connection.execute(sql).first["val"]
    end

    def self.get_current_progressive
        self.connection.execute("SELECT last_value FROM acube_invoice_records_progressive_seq").first["last_value"]
    end

    def self.reset_progressive
      self.connection.execute("ALTER SEQUENCE acube_invoice_records_progressive_seq MINVALUE 0")
      self.connection.execute("SELECT setval('acube_invoice_records_progressive_seq', 0)")
    end
  end
end

ActiveSupport.run_load_hooks :acube_invoice_record, ACube::InvoiceRecord