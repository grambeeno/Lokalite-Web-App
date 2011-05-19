class CreateUserOrganizationJoins < ActiveRecord::Migration
  def self.up
    create_table :user_organization_joins do |t|
      t.references :user
      t.references :organization
      t.string :kind

      t.timestamps
    end

    add_index :user_organization_joins, [:user_id]
    add_index :user_organization_joins, [:organization_id]
  end

  def self.down
    drop_table :user_organization_joins
  end
end
