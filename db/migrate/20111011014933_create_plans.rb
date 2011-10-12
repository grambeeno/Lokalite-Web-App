class CreatePlans < ActiveRecord::Migration
  def self.up
    create_table :plans do |t|
      t.references :user
      t.string :uuid
      t.string :title
      t.boolean :public, :default => false
      t.text :description
      t.text :event_list
      t.datetime :start_date

      t.timestamps
    end

    add_index :plans, [:user_id]
  end

  def self.down
    drop_table :plans
  end
end
