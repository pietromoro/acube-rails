class CreateACubeInvoices < ActiveRecord::Migration[7.0]
  def change
    primary_key_type, foreign_key_type = primary_and_foreign_key_types

    create_table :acube_invoices, id: primary_key_type do |t|
      t.references :record, null: false, polymorphic: true, index: false, type: foreign_key_type

      t.string :name, null: false
      t.string :webhook_uuid
      t.integer :status, null: false, default: 0
      t.integer :format, null: false
      t.integer :kind, null: false
      t.string :progressive, null: false
      t.text :json_body, size: :long
      t.text :xml_body, size: :long

      t.timestamps

      t.index [ :record_type, :record_id, :name ], name: "index_acube_rails_acube_invoices_uniqueness", unique: true
      t.index :progressive, unique: true
    end
  end

private
  def primary_and_foreign_key_types
    config = Rails.configuration.generators
    setting = config.options[config.orm][:primary_key_type]
    primary_key_type = setting || :primary_key
    foreign_key_type = setting || :bigint
    [primary_key_type, foreign_key_type]
  end
end
