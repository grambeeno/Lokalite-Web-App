class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations, :force => true do |t|
      t.string :uuid
      t.string :address
      t.string :formatted_address
      t.string :country
      t.string :administrative_area_level_1
      t.string :administrative_area_level_2
      t.string :locality
      t.string :prefix
      t.string :postal_code
      t.float :lat
      t.float :lng
      t.float :utc_offset

      t.text :json

      t.timestamps
    end

    add_index :locations, [:uuid], :unique => true
    add_index :locations, [:address], :unique => true
    add_index :locations, [:prefix]
    add_index :locations, [:country]
    add_index :locations, [:administrative_area_level_1]
    add_index :locations, [:administrative_area_level_2]
    add_index :locations, [:locality]
    add_index :locations, [:postal_code]
    add_index :locations, [:lat]
    add_index :locations, [:lng]

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

