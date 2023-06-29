# frozen_string_literal: true

module ACube
  class InvoiceRecord < ACube.invoice_base_class.constantize
    self.table_name = 'acube_invoice_records'

    belongs_to :record, polymorphic: true, touch: true
    has_one_attached :pdf

    enum format: %i[ FPA12 FPR12 ]
    enum kind: %i[ TD01 TD02 TD03 TD04 TD05 TD06 TD16 TD17 TD18 TD19 TD20 TD21 TD22 TD23 TD24 TD25 TD26 TD27 TD28 ]

    enum status: { error: -1, created: 0, sent: 1, downloaded: 2, not_received: 3, rejected: 4, delivered: 5 }
  end
end

ActiveSupport.run_load_hooks :acube_invoice_record, ACube::InvoiceRecord