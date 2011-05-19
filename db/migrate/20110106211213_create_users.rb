class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.string :uuid, :null => false
      t.string :email
      t.string :password
      t.string :time_zone, :default => User::DefaultTimeZone
      t.string :handle

      t.timestamps
    end

    add_index :users, [:uuid], :unique => true
    add_index :users, [:email], :unique => true
    add_index :users, [:password]
    add_index :users, [:handle]
    add_index :users, [:created_at]
    add_index :users, [:updated_at]
  end

  def self.down
    drop_table :users
  end
end
