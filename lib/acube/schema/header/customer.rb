module ACube
  module Schema
    module Header
      class Customer
        attr_accessor :vat_fiscal_id
        attr_accessor :fiscal_code
        attr_accessor :first_name, :last_name, :denomination, :title, :eori_code
        attr_accessor :address, :civic_number, :zip, :city, :province, :nation

        def to_xml
          
        end
      end
    end
  end
end