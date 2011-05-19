class CreateVenues < ActiveRecord::Migration
  def self.up
    create_table :venues, :force => true do |t|
      t.string :uuid
      t.string :name
      t.text :description
      t.string :address
      t.string :email
      t.string :url
      t.string :phone

      t.timestamps
    end

    create_table :venue_context_joins, :force => true do |t|
      t.integer :venue_id
      t.string :context_type
      t.integer :context_id
      t.string :kind
    end
    add_index :venue_context_joins, [:venue_id]
    add_index :venue_context_joins, [:context_type]
    add_index :venue_context_joins, [:context_id]
    add_index :venue_context_joins, [:kind]
    add_index :venue_context_joins, [:venue_id, :context_type, :context_id], :unique => true
    add_index :venue_context_joins, [:venue_id, :context_type, :context_id, :kind], :unique => true
  end

  def self.down
    drop_table :venues
  end
end
