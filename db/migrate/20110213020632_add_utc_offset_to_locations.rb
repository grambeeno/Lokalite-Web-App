class AddUtcOffsetToLocations < ActiveRecord::Migration
  def self.up
    unless column_exists?(:locations, :utc_offset)
      add_column(:locations, :utc_offset, :float)
    end

    Location.all.each do |location|
      location.calculate_utc_offset!
    end
  end

  def self.down
  end
end
