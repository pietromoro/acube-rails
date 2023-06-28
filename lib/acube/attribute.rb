module ACube
  module Attribute
    extend ActiveSupport::Concern

    class_methods do
      def has_invoice(name, strict_loading: strict_loading_by_default)
        class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{name}
            invoice_#{name} || build_invoice_#{name}
          end

          def #{name}?
            invoice_#{name}.present?
          end
        CODE
        
        include ACube::Transaction::Model
        has_one :"invoice_#{name}", -> { where(name: name) }, class_name: 'ACube::InvoiceRecord', as: :record, inverse_of: :record, autosave: true, dependent: :destroy, strict_loading: strict_loading
      end
    end
  end
end