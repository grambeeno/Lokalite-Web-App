class EnsureIndexesOnLocations < ActiveRecord::Migration
  def self.up
    unless table_exists?(:location_context_joins)
      create_table :location_context_joins, :force => true do |t|
        t.integer :location_id
        t.string :context_type
        t.integer :context_id
        t.string :kind
      end
    end

    remove_index :location_context_joins, [:id] rescue nil
    add_index :location_context_joins, [:id]

    remove_index :location_context_joins, [:location_id] rescue nil
    add_index :location_context_joins, [:location_id]

    remove_index :location_context_joins, [:context_type] rescue nil
    add_index :location_context_joins, [:context_type]

    remove_index :location_context_joins, [:context_id] rescue nil
    add_index :location_context_joins, [:context_id]

    remove_index :location_context_joins, [:kind] rescue nil
    add_index :location_context_joins, [:kind]

    remove_index :location_context_joins, [:location_id, :context_type, :context_id], :unique => true rescue nil
    add_index :location_context_joins, [:location_id, :context_type, :context_id], :unique => true

    remove_index :location_context_joins, [:location_id, :context_type, :context_id, :kind], :unique => true rescue nil
    add_index :location_context_joins, [:location_id, :context_type, :context_id, :kind], :unique => true
  end

  def self.down
  end
end
