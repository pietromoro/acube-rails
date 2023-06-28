module ACube
  module Transaction
    class Model
      extend ActiveSupport::Concern
      cattr_accessor(:transaction_data) { {} }

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
            puts @transaction_data
          else
            super 
          end
        end
      end

      class_methods do
      protected
        def as_transaction(&block)
          config = TransactionBuilder.new
          yield(config)
          transaction_data = config.finalize
        end
      end

      def to_transaction
        ACube::Schema::Body.new.from(self)
      end
    end
  end
end