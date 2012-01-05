class CreateEventFeatures < ActiveRecord::Migration
  def self.up
    create_table :event_features do |t|
      t.references :event
      t.date :date
      t.integer :slot

      t.timestamps
    end

    add_index :event_features, [:event_id, :date]
  end

  def self.down
    remove_index :event_features, :column => [:event_id, :date]

    drop_table :event_features
  end
end
