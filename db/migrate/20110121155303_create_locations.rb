class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations, :force => true do |t|
      t.string :uuid
      t.string :name
      t.string :street
      t.string :locality
      t.string :region
      t.string :postal_code
      t.string :country
      t.integer :organization_id

      t.float :utc_offset

      t.timestamps
    end

    add_index :locations, [:uuid], :unique => true
    add_index :locations, [:name]
    add_index :locations, [:locality]
    add_index :locations, [:postal_code]
  end

  def self.down
    drop_table :locations
  end
end
