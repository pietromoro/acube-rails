module ACube
  module Schema
    module Header
      class Customer
        attr_accessor :vat_fiscal_id
        attr_accessor :fiscal_code
        attr_accessor :first_name, :last_name, :denomination, :title, :eori_code
        attr_accessor :address, :civic_number, :zip, :city, :province, :nation

        def from(supplier)
          supplier.supplier_data.each do |key, value|
            value = value.is_a?(Symbol) ? supplier.send(value).to_s : value.to_s
            send("#{key}=", value)
          end
        end

        def to_xml
          fragment = Nokogiri::XML::DocumentFragment.new(Nokogiri::XML::Document.new)
          Nokogiri::XML::Builder.with(fragment) do |xml|
            xml.CessionarioCommittente {
              xml.DatiAnagrafici {
                xml.CodiceFiscale fiscal_code
                xml.Anagrafica {
                  xml.Nome first_name
                  xml.Cognome last_name
                }
              }
              xml.Sede {
                xml.Indirizzo address
                xml.NumeroCivico civic_number
                xml.CAP zip
                xml.Provincia province
                xml.Nazione nation
              }
            }
          end
        end
      end
    end
  end
end