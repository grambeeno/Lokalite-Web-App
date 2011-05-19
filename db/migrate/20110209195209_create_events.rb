class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events, :force => true do |t|
      t.string :uuid
      t.integer :organization_id
      t.string :name
      t.text :description
      t.timestamp :starts_at
      t.timestamp :ends_at
      t.boolean :all_day
      t.boolean :repeating
      t.integer :event_id
      t.text :search

      t.timestamps
    end

    add_index :events, [:organization_id]
    add_index :events, [:name]
    add_index :events, [:description]
    add_index :events, [:starts_at]
    add_index :events, [:ends_at]
    add_index :events, [:all_day]
    add_index :events, [:repeating]
    add_index :events, [:event_id]
  end

  def self.down
    drop_table :events
  end
end
