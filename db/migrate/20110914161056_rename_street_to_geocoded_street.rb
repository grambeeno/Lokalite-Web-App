class RenameStreetToGeocodedStreet < ActiveRecord::Migration
  def self.up
    rename_column :locations, :street, :geocoded_street

    Location.reset_column_information

    for location in Location.all
      location.user_given_street = location.geocoded_street
      location.save
    end
  end

  def self.down
    rename_column :locations, :geocoded_street, :street
  end
end
