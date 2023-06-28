# frozen_string_literal: true

module ACube
  class InvoiceRecord < ACube.invoice_base_class.constantize
    self.table_name = 'acube_invoice_records'

    belongs_to :record, polymorphic: true, touch: true
    has_one_attached :pdf
  end
end

ActiveSupport.run_load_hooks :acube_invoice_record, ACube::InvoiceRecord