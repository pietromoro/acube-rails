class CreateACubeInvoiceRecords < ActiveRecord::Migration[7.0]
  def up
    if connection.adapter_name.downcase != 'postgresql'
      raise "This migration is only compatible with PostgreSQL at the moment."
    end

    primary_key_type, foreign_key_type = primary_and_foreign_key_types

    create_table :acube_invoice_records, id: primary_key_type do |t|
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

      t.index [ :record_type, :record_id, :name ], name: "index_acube_rails_acube_invoice_records_uniqueness", unique: true
      t.index :progressive, unique: true
      t.index :webhook_uuid, unique: true
    end

    execute <<-SQL
      CREATE SEQUENCE acube_invoice_records_progressive_seq START 1 INCREMENT 1 OWNED BY acube_invoice_records.progressive;
    SQL

    ACube::Schema::Body::DOCUMENT_KINDS.each do |kind|
      execute <<-SQL
        CREATE SEQUENCE acube_invoice_records_progressive_#{kind}_seq START 1 INCREMENT 1 OWNED BY acube_invoice_records.progressive;
      SQL
    end
  end
  
  def down
    drop_table :acube_invoice_records
    execute "DROP SEQUENCE IF EXISTS acube_invoice_records_progressive_seq;"
    ACube::Schema::Body::DOCUMENT_KINDS.each do |kind|
      execute "DROP SEQUENCE IF EXISTS acube_invoice_records_progressive_#{kind}_seq;"
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
