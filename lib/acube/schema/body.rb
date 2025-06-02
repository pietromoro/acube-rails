module ACube
  module Schema
    class Body
      DOCUMENT_KINDS = %w[TD01 TD02 TD03 TD04 TD05 TD06 TD16 TD17 TD18 TD19 TD20 TD21 TD22 TD23 TD24 TD25 TD26 TD27 TD28].freeze
      PAYMENT_METHODS = %w[MP01 MP02 MP03 MP04 MP05 MP06 MP07 MP08 MP09 MP10 MP11 MP12 MP13 MP14 MP15 MP16 MP17 MP18 MP19 MP20 MP21 MP22 MP23].freeze

      class Item
        VAT_EXEMPTIONS = %w[N1 N2.1 N2.2 N3.1 N3.3 N3.4 N3.5 N3.6 N4 N5 N6.1 N6.2 N6.3 N6.4 N6.5 N6.6 N6.7 N6.8 N6.9 N7].freeze

        attr_accessor :description
        attr_accessor :quantity
        attr_accessor :vat_exemption
        attr_accessor :total
        attr_reader :current_line

        def set_current_line line
          @current_line = line
        end

        def to_xml
          Nokogiri::XML::Builder.new do |xml|
            xml.DettaglioLinee {
              xml.NumeroLinea current_line
              xml.Descrizione description
              xml.Quantita ("%.2f" % quantity.to_f) if quantity != 0

              if vat_exemption
                raise "Unknown VAT exemption code" unless VAT_EXEMPTIONS.include? vat_exemption
                xml.PrezzoUnitario ("%.2f" % total.to_f)
                xml.PrezzoTotale ("%.2f" % total.to_f)
                xml.AliquotaIVA ("0.00")
                xml.Natura (vat_exemption.to_s)
              else
                xml.PrezzoUnitario ("%.2f" % unitary_price.to_f)
                xml.PrezzoTotale ("%.2f" % total_no_vat.to_f)
                xml.AliquotaIVA ("%.2f" % (ACube.vat_amount * 100).to_f)
              end
            }
          end.to_xml(save_with: 2)
        end

        def vatable_total
          if vat_exemption
            total
          else
            total_no_vat
          end
        end

        def unitary_price
          total_no_vat / quantity
        end

        def total_no_vat
          total / ((100 + (ACube.vat_amount * 100)) / 100)
        end

        def vat_amount
          total - total_no_vat
        end
      end

      attr_accessor :document_kind, :date
      attr_accessor :connected_progressive
      attr_accessor :causal
      attr_accessor :payment_max_date
      attr_accessor :payment_terms, :payment_method
      attr_accessor :items
      attr_reader :progressive

      def self.from(invoice)
        new.tap do |body|
          invoice.transaction_data.each do |key, value|
            value = value.is_a?(Symbol) ? invoice.send(value) : value
            body.send("#{key}=", value)
          end

          raise "ACube: Unknown items" unless body.items.is_a?(Array)
          raise "ACube: At least one item is required" unless body.items.length > 0

          body.items.map!.with_index do |item, idx|
            raise "ACube: Unknown item format" unless item.is_a?(Hash)

            new_item = Item.new()
            new_item.set_current_line idx + 1
            item.each do |key, value|
              new_item.send("#{key}=", value)
            end
            new_item
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
                xml.ImportoTotaleDocumento ("%.2f" % total_price.to_f)
                xml.Causale causal if causal
              }

              if (document_kind == :TD04)
                xml.DatiFattureCollegate {
                  xml.IdDocumento connected_progressive
                }
              end
            }

            xml.DatiBeniServizi {
              items.each do |item|
                xml << item.to_xml
              end

              items.each_with_object(Hash.new {|h, k| h[k] = [0, 0]}) do |item, h|
                h[item.vat_exemption][0] += item.vatable_total 
                h[item.vat_exemption][1] += item.vat_amount 
              end.each do |vat_exemption, (total, vat_amount)|
                xml.DatiRiepilogo {
                  xml.AliquotaIVA ("%.2f" % (ACube.vat_amount * 100).to_f) unless vat_exemption
                  xml.AliquotaIVA ("0.00") if vat_exemption
                  xml.Natura vat_exemption if vat_exemption

                  xml.ImponibileImporto ("%.2f" % total.to_f)

                  xml.Imposta ("%.2f" % vat_amount.to_f) unless vat_exemption
                  xml.Imposta ("0.00") if vat_exemption

                  xml.EsigibilitaIVA "I"
                }
              end
            }

            xml.DatiPagamento {
              xml.CondizioniPagamento payment_terms
              xml.DettaglioPagamento {
                xml.ModalitaPagamento payment_method
                xml.DataScadenzaPagamento payment_max_date.strftime("%Y-%m-%d")
                xml.ImportoPagamento ("%.2f" % total_price.to_f)
              }
            }
          }
        end.to_xml(save_with: 2)
      end

    private
      def total_price
        @total_price ||= items.map(&:total).sum
      end
    end
  end
end