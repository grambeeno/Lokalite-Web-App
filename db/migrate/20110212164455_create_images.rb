class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images, :force => true do |t|
      t.string :image
      t.timestamps
    end

    create_table :image_context_joins, :force => true do |t|
      t.integer :image_id
      t.string :context_type
      t.integer :context_id
      t.string :kind
    end
    add_index :image_context_joins, [:context_type]
    add_index :image_context_joins, [:context_id]
    add_index :image_context_joins, [:image_id]
    add_index :image_context_joins, [:kind]
    add_index :image_context_joins, [:context_type, :context_id, :image_id], :unique => true, :name => 'image_context_type_with_ids'
    add_index :image_context_joins, [:context_type, :context_id, :kind, :image_id], :unique => true, :name => 'image_context_type_with_kind_and_id'
  end

  def self.down
    drop_table :images
  end
end
