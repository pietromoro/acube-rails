module ACube
  module Consumer
    module Model
      extend ActiveSupport::Concern
      cattr_accessor(:consumer_data) { {} }

      class ConsumerBuilder
        @@attributes = ACube::Schema::Header::consumer.instance_methods.select {|m| m.ends_with?("=") && m.starts_with?(/\w/) }
        @consumer_data = {}

        def initialize
          @consumer_data = {}
        end

        def finalize
          @consumer_data
        end
        
        def method_missing(method, value)
          if (@@attributes.include?(method))
            @consumer_data[method[0..-2]] = value
            puts @consumer_data
          else
            super 
          end
        end
      end

      class_methods do
      protected
        def as_consumer(&block)
          config = ConsumerBuilder.new
          yield(config)
          consumer_data = config.finalize
        end
      end

      def to_consumer
        ACube::Schema::Header::Consumer.new.from(self)
      end
    end
  end
end