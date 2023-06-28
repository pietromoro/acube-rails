module ACube
  module Schema
    module Header
      class Header
        TRANSMISSION_FORMATS = %w[FPR12]
        attr_accessor :supplier, :customer
        attr_accessor :transmission_format

        def initialize(supplier, customer, format)
          @supplier = supplier
          @customer = customer
          raise ArgumentError.new("Format #{format} is unknown") unless TRANSMISSION_FORMATS.include?(format)
          @transmission_format = format
        end

        def to_xml
          fragment = Nokogiri::XML::DocumentFragment.new(Nokogiri::XML::Document.new)
          Nokogiri::XML::Builder.with(fragment) do |xml|
            xml.FatturaElettronicaHeader {
              xml.DatiTrasmissione {
                xml.IdTrasmittente {
                  xml.IdPaese ACube.transmission_nation_id
                  xml.IdCodice ACube.transmission_id_code
                }
                xml.FormatoTrasmissione transmission_format
                xml.CodiceDestinatario "0000000"
              }
            }
          end
        end
      end
    end
  end
end