module ACube
  module Schema
    module Header
      class Header
        attr_accessor :supplier, :customer

        def initialize(supplier, customer)
          @supplier = supplier
          @customer = customer
        end

        def to_xml
          
        end
      end
    end
  end
end