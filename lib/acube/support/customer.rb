module ACube
  module Support
    module Customer
      extend ActiveSupport::Concern
      cattr_reader :customer_data
      
      included do
      protected
        def self.as_customer(&block)
          config = CustomerBuilder.new
          yield(config)
          @@customer_data = config.finalize.dup
        end
      end

      class CustomerBuilder
        @@attributes = ACube::Schema::Header::Customer.instance_methods.select {|m| m.ends_with?("=") && m.starts_with?(/\w/) }
        @customer_data = {}

        def initialize
          @customer_data = {}
        end

        def finalize
          @customer_data
        end
        
        def method_missing(method, value)
          if (@@attributes.include?(method))
            @customer_data[method[0..-2]] = value
          else
            super 
          end
        end
      end

      def to_customer
        ACube::Schema::Header::Customer.from(self)
      end
    end
  end
end