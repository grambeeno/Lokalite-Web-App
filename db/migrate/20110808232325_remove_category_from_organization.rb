class RemoveCategoryFromOrganization < ActiveRecord::Migration
  def self.up
    remove_column :organizations, :category
  end

  def self.down
    add_column :organizations, :category
  end
end
