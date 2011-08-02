class AddVenueFieldsToLocationAndRemoveVenue < ActiveRecord::Migration
  def self.up
    add_column :locations, :name, :string
    add_column :locations, :organization_id, :integer
    remove_column :locations, :address
    remove_column :organizations, :address
    remove_column :events, :all_day

    add_column :events, :location_id, :integer
  end

  def self.down
    remove_column :events, :location_id

    add_column :events, :all_day
    add_column :organizations, :address
    add_column :locations, :address
    remove_column :locations, :organization_id
    remove_column :locations, :name
  end
end
