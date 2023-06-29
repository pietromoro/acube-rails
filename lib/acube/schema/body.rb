module ACube
  module Schema
    class Body
      attr_accessor :document_kind, :date
      attr_accessor :total_price
      attr_accessor :connected_progressive
      attr_accessor :description
      attr_accessor :quantity
      attr_accessor :causal
      attr_accessor :payment_max_date
      attr_accessor :payment_terms, :payment_method
      attr_reader :progressive

      def self.from(invoice)
        new.tap do |body|
          invoice.transaction_data.each do |key, value|
            value = value.is_a?(Symbol) ? invoice.send(value) : value
            body.send("#{key}=", value)
          end
        end
      end

      def set_progressive(progressive)
        @progressive = progressive
      end
      
      def to_xml
        Nokogiri::XML::Builder.new do |xml|
          xml.FatturaElettronicaBody {
            xml.DatiGenerali {
              xml.DatiGeneraliDocumento {
                xml.TipoDocumento document_kind
                xml.Divisa "EUR"
                xml.Data date.strftime("%Y-%m-%d")
                xml.Numero progressive
                xml.ImportoTotaleDocumento total_price
                xml.Causale causal if causal
              }

              if (document_kind == :TD04)
                xml.DatiFattureCollegate {
                  xml.IdDocumento connected_progressive
                }
              end
            }

            xml.DatiBeniServizi {
              xml.DettaglioLinee {
                xml.NumeroLinea 1
                xml.Descrizione description
                xml.Quantita ("%f" % quantity.to_f)
                xml.PrezzoUnitario ("%f" % unitary_price.to_f)
                xml.PrezzoTotale ("%f" % price_no_vat.to_f)
                xml.AliquotaIVA ("%.2f" % (ACube.vat_amount * 100).to_f)
              }

              xml.DatiRiepilogo {
                xml.AliquotaIVA ("%.2f" % (ACube.vat_amount * 100).to_f)
                xml.ImponibileImporto ("%f" % unitary_price.to_f)
                xml.Imposta ("%f" % vat_amount.to_f)
                xml.EsigibilitaIVA "I"
              }
            }

            xml.DatiPagamento {
              xml.CondizioniPagamento payment_terms
              xml.DettaglioPagamento {
                xml.ModalitaPagamento payment_method
                xml.DataScadenzaPagamento payment_max_date.strftime("%Y-%m-%d")
                xml.ImportoPagamento ("%f" % total_price.to_f)
              }
            }
          }
        end.to_xml(save_with: 2)
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