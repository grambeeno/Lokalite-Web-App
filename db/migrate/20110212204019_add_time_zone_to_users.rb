class AddTimeZoneToUsers < ActiveRecord::Migration
  def self.up
    unless column_exists?(:users, :time_zone)
      add_column :users, :time_zone, :string, :default => User::DefaultTimeZone
    end
  end

  def self.down
  end
end
