class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses, :force => true do |t|
      t.string :context_type
      t.integer :context_id
      t.text :content

      t.timestamps
    end

    add_index :statuses, [:context_type]
    add_index :statuses, [:context_id]
    add_index :statuses, [:created_at]
  end

  def self.down
    drop_table :statuses
  end
end
