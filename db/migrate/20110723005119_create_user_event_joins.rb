class CreateUserEventJoins < ActiveRecord::Migration
  def self.up
    create_table :user_event_joins do |t|
      t.references :user
      t.references :event

      t.timestamps
    end

    add_column :events, :users_count, :integer, :default => 0
  end

  def self.down
    remove_column :events, :users_count
    drop_table :user_event_joins
  end
end
