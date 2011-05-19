class AddTimeZoneToUsers < ActiveRecord::Migration
  def self.up
    unless column_exists?(:users, :time_zone)
      add_column :users, :time_zone, :string, :default => User::DefaultTimeZone
    end

    User.all.each do |user|
      user.update_attributes! :time_zone => User::DefaultTimeZone
      user.save!
    end
  end

  def self.down
  end
end
