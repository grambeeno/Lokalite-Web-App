class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories, :force => true do |t|
      t.string :name
      t.integer :position

      t.timestamps
    end
    add_index :categories, [:name], :unique => true

    create_table :category_context_joins, :force => true do |t|
      t.integer :category_id
      t.string :context_type
      t.string :kind
      t.integer :context_id
    end
    add_index :category_context_joins, [:category_id]
    add_index :category_context_joins, [:context_type]
    add_index :category_context_joins, [:context_id]
    add_index :category_context_joins, [:kind]
    add_index :category_context_joins, [:category_id, :context_type, :context_id], :unique => true
    add_index :category_context_joins, [:category_id, :context_type, :context_id, :kind], :unique => true
  end

  def self.down
    drop_table :categories
  end
end
