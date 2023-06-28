module ACube
  module Schema
    module Header
      class Supplier
        FISCAL_REGIMES = %w[RF01 RF02 RF04 RF05 RF06 RF07 RF08 RF09 RF10 RF11 RF12 RF13 RF14 RF15 RF16 RF17 RF18 RF19]

        attr_accessor :id_nation, :id_tax_code
        attr_accessor :fiscal_code
        attr_accessor :first_name, :last_name, :denomination, :title, :eori_code
        attr_accessor :albo_professional, :albo_subscription, :albo_subscription_date
        attr_accessor :fiscal_regime
        attr_accessor :address, :civic_number, :zip, :city, :province, :nation

        def from(supplier)
          supplier.supplier_data.each do |key, value|
            value = value.is_a?(Symbol) ? supplier.send(value).to_s : value.to_s
            send("#{key}=", value)
          end
        end

        def to_xml

        end
      end
    end
  end
end