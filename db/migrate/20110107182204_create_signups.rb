class CreateSignups < ActiveRecord::Migration
  def self.up
    create_table :signups, :force => true do |t|
      t.string :email
      t.string :password
      t.references :user
      t.integer :delivery_count, :default => 0

      t.timestamps
    end

    add_index :signups, [:email], :unique => true
    add_index :signups, [:user_id]
    add_index :signups, [:delivery_count]
  end

  def self.down
    drop_table :signups
  end
end
