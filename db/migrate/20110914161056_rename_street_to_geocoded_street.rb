class RenameStreetToGeocodedStreet < ActiveRecord::Migration
  def self.up
    rename_column :locations, :street, :geocoded_street
  end

  def self.down
    rename_column :locations, :geocoded_street, :street
  end
end
