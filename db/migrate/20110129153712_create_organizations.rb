class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table :organizations, :force => true do |t|
      t.string :uuid
      t.string :name
      t.text   :description
      t.string :email
      t.string :url
      t.string :phone
      t.string :category
      t.string :image

      t.timestamps
    end

    add_index :organizations, [:uuid], :unique => true
    add_index :organizations, [:name]
    add_index :organizations, [:category]
  end

  def self.down
    drop_table :organizations
  end
end
