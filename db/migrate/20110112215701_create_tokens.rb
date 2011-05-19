class CreateTokens < ActiveRecord::Migration
  def self.up
    create_table :tokens, :force => true do |t|
      t.string :uuid
      t.string :kind
      t.references :context, :polymorphic => true
      t.integer :counter, :default => 0
      t.timestamp :expires_at
      t.text :data, :default => Hash.new.to_yaml

      t.timestamps
    end

    add_index :tokens, [:uuid], :unique => true
    add_index :tokens, [:kind]
    add_index :tokens, [:context_type]
    add_index :tokens, [:context_id]
    add_index :tokens, [:counter]
    add_index :tokens, [:expires_at]
  end

  def self.down
    drop_table :tokens
  end
end
