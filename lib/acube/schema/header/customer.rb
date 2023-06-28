module ACube
  module Schema
    module Header
      class Customer
        attr_accessor :vat_fiscal_id
        attr_accessor :fiscal_code
        attr_accessor :first_name, :last_name, :denomination, :title, :eori_code
        attr_accessor :address, :civic_number, :zip, :city, :province, :nation

        def self.from(customer)
          new.tap do |cust|
            customer.customer_data.each do |key, value|
              value = value.is_a?(Symbol) ? customer.send(value).to_s : value.to_s
              cust.send("#{key}=", value)
            end
          end
        end

        def to_xml
          fragment = Nokogiri::XML::DocumentFragment.new(Nokogiri::XML::Document.new)
          Nokogiri::XML::Builder.with(fragment) do |xml|
            xml.CessionarioCommittente {
              xml.DatiAnagrafici {
                xml.CodiceFiscale fiscal_code
                xml.Anagrafica {
                  if (first_name && last_name)
                    xml.Nome first_name
                    xml.Cognome last_name
                  else
                    xml.Denominazione denomination
                  end
                  xml.Titolo title if title
                  xml.CodEORI eori_code if eori_code
                }
              }
              xml.Sede {
                xml.Indirizzo address
                xml.NumeroCivico civic_number if civic_number
                xml.CAP zip
                xml.Comune city
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