class CreateRoles < ActiveRecord::Migration
  def self.up
  # roles table
  #
    create_table :roles, :force => true do |t|
      t.string :name
      t.timestamps
    end
    add_index :roles, :name
    
  # generate the join table
  #
    create_table :user_role_joins, :force => true do |t|
      t.integer :role_id, :user_id
      t.boolean :primary, :default => true
      t.timestamps
    end

    add_index :user_role_joins, :role_id
    add_index :user_role_joins, :user_id
    add_index :user_role_joins, :primary

    Role.names.each do |name|
      Role.create!(:name => name)
    end
  end

  def self.down
    drop_table :roles
    drop_table :user_role_joins
  end
end
