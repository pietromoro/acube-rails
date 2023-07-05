module ACube
  module Schema
    class Body
      DOCUMENT_KINDS = %w[TD01 TD02 TD03 TD04 TD05 TD06 TD16 TD17 TD18 TD19 TD20 TD21 TD22 TD23 TD24 TD25 TD26 TD27 TD28].freeze
      PAYMENT_METHODS = %w[MP01 MP02 MP03 MP04 MP05 MP06 MP07 MP08 MP09 MP10 MP11 MP12 MP13 MP14 MP15 MP16 MP17 MP18 MP19 MP20 MP21 MP22 MP23].freeze

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
                xml.ImportoTotaleDocumento ("%06.2f" % total_price.to_f)
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
                xml.Quantita ("%06.2f" % quantity.to_f)
                xml.PrezzoUnitario ("%06.2f" % unitary_price.to_f)
                xml.PrezzoTotale ("%06.2f" % price_no_vat.to_f)
                xml.AliquotaIVA ("%.2f" % (ACube.vat_amount * 100).to_f)
              }

              xml.DatiRiepilogo {
                xml.AliquotaIVA ("%.2f" % (ACube.vat_amount * 100).to_f)
                xml.ImponibileImporto ("%06.2f" % price_no_vat.to_f)
                xml.Imposta ("%06.2f" % vat_amount.to_f)
                xml.EsigibilitaIVA "I"
              }
            }

            xml.DatiPagamento {
              xml.CondizioniPagamento payment_terms
              xml.DettaglioPagamento {
                xml.ModalitaPagamento payment_method
                xml.DataScadenzaPagamento payment_max_date.strftime("%Y-%m-%d")
                xml.ImportoPagamento ("%06.2f" % total_price.to_f)
              }
            }
          }
        end.to_xml(save_with: 2)
      end

    private
      def unitary_price
        price_no_vat / quantity
      end

      def price_no_vat
        total_price / ((100 + (ACube.vat_amount * 100)) / 100)
      end

      def vat_amount
        total_price - price_no_vat
      end
    end
  end
end