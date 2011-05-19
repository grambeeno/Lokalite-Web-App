class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions, :force => true do |t|
      t.text :data, :default => Hash.new.to_yaml

      t.references :user, :null => false

      t.timestamps
    end

    add_index :sessions, :user_id, :unique => true
  end

  def self.down
    drop_table :sessions
  end
end

