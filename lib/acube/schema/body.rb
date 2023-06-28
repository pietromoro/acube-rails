module ACube
  module Schema
    class Body
      attr_accessor :document_kind, :date, :progressive
      attr_accessor :total_price
      attr_accessor :connected_progressive
      attr_accessor :description
      attr_accessor :quantity

      def self.from(invoice)
      end
      
      def to_xml
        fragment = Nokogiri::XML::DocumentFragment.new(Nokogiri::XML::Document.new)
        Nokogiri::XML::Builder.with(fragment) do |xml|
          xml.FatturaElettronicaBody {
            xml.DatiGenerali {
              xml.DatiGeneraliDocumento {
                xml.TipoDocumento document_kind
                xml.Divisa "EUR"
                xml.Data date.strfy_time("%Y-%m-%d")
                xml.Numero progressive
                xml.ImportoTotaleDocumento total_price
                xml.Causale causal
              }

              if (document_kind == :TD01 || document_kind == :TD04)
                xml.DatiFattureCollegate {
                  xml.IdDocumento connected_progressive
                }
              end
            }

            xml.DatiBeniServizi {
              xml.DettaglioLinee {
                xml.NumeroLinea 1
                xml.Descrizione description
                xml.Quantita quantity.to_f.to_s
                xml.PrezzoUnitario unitary_price
                xml.PrezzoTotale price_no_vat
                xml.AliquotaIVA ACube.vat_amount * 100
              }

              xml.DatiRiepilogo {
                xml.AliquotaIVA ACube.vat_amount * 100
                xml.ImponibileImporto unitary_price
                xml.Imposta vat_amount
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

      private
        def unitary_price
          total_price / quantity
        end

        def price_no_vat
          total_price - vat_amount
        end

        def vat_amount
          total_price * ACube.vat_amount
        end
      end
    end
  end
end