class AddASearchFieldToOrganizations < ActiveRecord::Migration
  def self.up
    unless column_exists?(:organizations, :search)
      add_column(:organizations, :search, :text)
    end
  end

  def self.down
  end
end
