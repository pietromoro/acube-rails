module ACube
  module Support
    module Transaction
      extend ActiveSupport::Concern
      cattr_reader :transaction_data

      included do
      protected
        def self.as_transaction(&block)
          config = TransactionBuilder.new
          yield(config)
          @@transaction_data = config.finalize.dup
        end
      end

      class TransactionBuilder
        @@attributes = ACube::Schema::Body.instance_methods.select {|m| m.ends_with?("=") && m.starts_with?(/\w/) }
        @transaction_data = {}

        def initialize
          @transaction_data = {}
        end

        def finalize
          @transaction_data
        end
        
        def method_missing(method, value)
          if (@@attributes.include?(method))
            @transaction_data[method[0..-2]] = value
          else
            super 
          end
        end
      end

      def to_transaction
        ACube::Schema::Body.from(self)
      end
    end
  end
end