module ACube
  module Schema
    module Header
      class Supplier
        FISCAL_REGIMES = %w[RF01 RF02 RF03 RF04 RF05 RF06 RF07 RF08 RF09 RF10 RF11 RF12 RF13 RF14 RF15 RF16 RF17 RF18 RF19].freeze

        attr_accessor :id_nation, :id_tax_code
        attr_accessor :fiscal_code
        attr_accessor :first_name, :last_name, :denomination, :title, :eori_code
        attr_accessor :albo_professional, :aldo_province, :albo_subscription, :albo_subscription_date
        attr_accessor :fiscal_regime
        attr_accessor :address, :civic_number, :zip, :city, :province, :nation

        def self.from(supplier)
          new.tap do |supp|
            supplier.supplier_data.each do |key, value|
              value = value.is_a?(Symbol) ? supplier.send(value).to_s : value.to_s
              supp.send("#{key}=", value)
            end
          end
        end

        def to_xml
          Nokogiri::XML::Builder.new do |xml|
            xml.CedentePrestatore {
              xml.DatiAnagrafici {
                xml.IdFiscaleIVA {
                  xml.IdPaese id_nation
                  xml.IdCodice id_tax_code
                }
                
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

                xml.RegimeFiscale fiscal_regime
                xml.CodiceFiscale fiscal_code if fiscal_code

                xml.AlboProfessionale albo_professional if albo_professional
                xml.ProvinciaAlbo aldo_province if aldo_province
                xml.NumeroIscrizioneAlbo albo_subscription if albo_subscription
                xml.DataIscrizioneAlbo albo_subscription_date if albo_subscription_date
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
          end.to_xml(save_with: 2)
        end
      end
    end
  end
end