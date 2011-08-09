class AddUtcOffsetToLocations < ActiveRecord::Migration
  def self.up
    unless column_exists?(:locations, :utc_offset)
      add_column(:locations, :utc_offset, :float)
    end
  end

  def self.down
  end
end
