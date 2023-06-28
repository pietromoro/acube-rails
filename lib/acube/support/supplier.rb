module ACube
  module Support
    module Supplier
      extend ActiveSupport::Concern
      cattr_accessor(:supplier_data) { {} }

      class SupplierBuilder
        @@attributes = ACube::Schema::Header::Supplier.instance_methods.select {|m| m.ends_with?("=") && m.starts_with?(/\w/) }
        @supplier_data = {}

        def initialize
          @supplier_data = {}
        end

        def finalize
          @supplier_data
        end
        
        def method_missing(method, value)
          if (@@attributes.include?(method))
            @supplier_data[method[0..-2]] = value
          else
            super 
          end
        end
      end

      class_methods do
      protected
        def as_supplier(&block)
          config = SupplierBuilder.new
          yield(config)
          supplier_data = config.finalize
        end
      end

      def to_supplier
        ACube::Schema::Header::Supplier.from(self)
      end
    end
  end
end