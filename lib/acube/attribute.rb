module ACube
  module Attribute
    extend ActiveSupport::Concern

    class_methods do
      def has_one_invoice(name, strict_loading: strict_loading_by_default)
        class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{name}
            invoice_record_#{name} || build_invoice_record_#{name}
          end

          def publish_#{name}!(supplier, customer, format, progressive_uses_variant: true)
            builder = ACube::Invoicer.from(supplier: supplier, customer: customer, invoice: self, format: format)
            builder.create_invoice(self, "#{name}", progressive_uses_variant: progressive_uses_variant)
          end

          def #{name}?
            invoice_record_#{name}.present?
          end
        CODE
        
        include ACube::Support::Transaction
        has_one :"invoice_record_#{name}", -> { where(name: name) }, class_name: 'ACube::InvoiceRecord', as: :record, inverse_of: :record, autosave: true, dependent: :destroy, strict_loading: strict_loading
      end

      def with_all_invoice_records
        eager_load(invoice_record_association_names)
      end

      def invoice_record_association_names
        reflect_on_all_associations(:has_one).collect(&:name).select { |n| n.start_with?("invoice_record_") }
      end
    end
  end
end