module ACube
  module Attribute
    extend ActiveSupport::Concern

    class_methods do
      def has_invoice(name)
        class_eval <<-CODE, __FILE__, __LINE__ + 1
        CODE

        has_one :"invoice_#{name}", -> { where(name: name) }
      end
    end
  end
end