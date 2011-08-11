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

    # create_table :location_context_joins, :force => true do |t|
    #   t.integer :location_id
    #   t.string :context_type
    #   t.integer :context_id
    #   t.string :kind
    # end
    # add_index :location_context_joins, [:location_id]
    # add_index :location_context_joins, [:context_type]
    # add_index :location_context_joins, [:context_id]
    # add_index :location_context_joins, [:kind]
    # add_index :location_context_joins, [:location_id, :context_type, :context_id], :unique => true
    # add_index :location_context_joins, [:location_id, :context_type, :context_id, :kind], :unique => true
  end

  def self.down
    drop_table :locations
  end
end

__END__
"country": "united_states",
"administrative_area_level_1": "colorado",
"administrative_area_level_2": "boulder",
"locality": "boulder",
"postal_code": "80302",
"prefix": "/united_states/colorado/boulder/boulder",
"address": "2030 17th St, Boulder, CO 80302, USA"

