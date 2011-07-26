# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#


User.all.each do |user|
  user.update_attributes! :time_zone => User::DefaultTimeZone
  user.save!
end


# Location.all.each do |location|
#   location.calculate_utc_offset!
# end

# Category.categories.each do |category|
#   Category.add!(category)
# end

# Event.index!
# Organization.index!
