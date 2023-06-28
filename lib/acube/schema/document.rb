module ACube
  module Schema
    class Document
      attr_accessor :body, :header
      attr_accessor :progressive, :transmission_format

      def initialize(header, body)
        @header = header
        @body = body
      end

      def fill_with(transmission_format:, progressive:)
        @transmission_format = transmission_format
        @progressive = progressive

        header.transmission_format = transmission_format
        header.progressive = progressive
        body.set_progressive(progressive)
      end

      def to_xml
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml["p"].FatturaElettronica(
            "versione" => header.transmission_format,
            "xmlns:ds" => "http://www.w3.org/2000/09/xmldsig#",
            "xmlns:p" => "http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2",
            "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
            "xsi:schemaLocation" => "http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2 http://www.fatturapa.gov.it/export/fatturazione/sdi/fatturapa/v1.2/Schema_del_file_xml_FatturaPA_versione_1.2.xsd"
          ) do
            xml << header.to_xml.to_xml
            xml << body.to_xml.to_xml
          end
        end
      end
    end
  end
end