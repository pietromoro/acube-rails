module ACube
  module Schema
    class Body
      attr_accessor :document_type, :date, :progressive, :total_import, :causal, :document_date, :document_id, :description, :unitary_price, :total_price, :imposible, :payment_max_date

      def to_xml
        fragment = Nokogiri::XML::DocumentFragment.new(Nokogiri::XML::Document.new)
        Nokogiri::XML::Builder.with(fragment) do |xml|
          xml.FatturaElettronicaBody {
            xml.DatiGenerali {
              xml.DatiGeneraliDocumento {
                xml.TipoDocumento document_type
                xml.Divisa "EUR"
                xml.Data date
                xml.Numero progressive
                xml.ImportoTotaleDocumento total_import
                xml.Causale causal
              }
              xml.DatiFattureCollegate {
                xml.IdDocumento document_id
                xml.Data document_date
              }
            }
            xml.DatiBeniServizi {
              xml.DettaglioLinee {
                xml.NumeroLinea 1
                xml.Descrizione description
                xml.Quantita 1.00000000
                xml.PrezzoUnitario unitary_price
                xml.PrezzoTotale total_price
                xml.AliquotaIVA 22.00
              }
              xml.DatiRiepilogo {
                xml.AliquotaIVA 22.00
                xml.ImponibileImporto unitary_price
                xml.Imposta imposible
                xml.EsigibilitaIVA "I"
              }
            }
            xml.DatiPagamento {
              xml.CondizioniPagamento "TP02"
              xml.DettaglioPagamento {
                xml.ModalitaPagamento "MP05"
                xml.DataScadenzaPagamento payment_max_date
                xml.ImportoPagamento total_price
              }
            }
          }
        end
      end
    end
  end
end