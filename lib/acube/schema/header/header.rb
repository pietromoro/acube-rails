module ACube
  module Schema
    module Header
      class Header
        attr_accessor :supplier, :customer
        attr_accessor :transmission_format
        attr_accessor :progressive

        def initialize(supplier, customer)
          @supplier = supplier
          @customer = customer
        end

        def to_xml
          Nokogiri::XML::Builder.new do |xml|
            xml.FatturaElettronicaHeader {
              xml.DatiTrasmissione {
                xml.IdTrasmittente {
                  xml.IdPaese ACube.transmission_nation_id
                  xml.IdCodice ACube.transmission_id_code
                }

                xml.ProgressivoInvio progressive
                xml.FormatoTrasmissione transmission_format
                xml.CodiceDestinatario "0000000"
              }
              
              xml << supplier.to_xml
              xml << customer.to_xml
            }
          end.to_xml(save_with: 2)
        end
      end
    end
  end
end