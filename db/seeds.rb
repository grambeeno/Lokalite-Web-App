# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

require 'open-uri'


User.destroy_all
Organization.destroy_all
Location.destroy_all
Image.destroy_all
Event.destroy_all


User.create! :email => 'admin@lokalite.com', :password => 'password'
User.create! :email => 'zef@madebykiwi.com', :password => 'password'

locations = [
  {
    :address_line_one => '417 Harvard Ln.',
    :address_line_two => '',
    :address_city     => 'Boulder',
    :address_state    => 'Colorado',
    :address_zip      => '80305'
  },
  {
    :address_line_one => '1226 Pennsylvania Ave.',
    :address_line_two => '#2',
    :address_city     => 'Boulder',
    :address_state    => 'Colorado',
    :address_zip      => '80302'
  },
  {
    :address_line_one => '1320 Pearl St.',
    :address_line_two => 'Suite 110',
    :address_city     => 'Boulder',
    :address_state    => 'Colorado',
    :address_zip      => '80302'
  },
  {
    :address_line_one => '2218 Edgewood Dr.',
    :address_line_two => '',
    :address_city     => 'Boulder',
    :address_state    => 'Colorado',
    :address_zip      => '80302'
  },
  {
    :address_line_one => '454 Arapahoe Ave.',
    :address_line_two => '#3',
    :address_city     => 'Boulder',
    :address_state    => 'Colorado',
    :address_zip      => '80302'
  },
  {
    :address_line_one => '1145 Pennsylvania Ave',
    :address_line_two => '#5',
    :address_city     => 'Boulder',
    :address_state    => 'Colorado',
    :address_zip      => '80302'
  },
  {
    :address_line_one => '3000 Center Green Dr',
    :address_line_two => 'Suite 140',
    :address_city     => 'Boulder',
    :address_state    => 'Colorado',
    :address_zip      => '80301'
  },
  {
    :address_line_one => ' 3198 Broadway',
    :address_line_two => '',
    :address_city     => 'Boulder',
    :address_state    => 'Colorado',
    :address_zip      => '80304'
  },
  {
    :address_line_one => '3600 Table Mesa Drive',
    :address_line_two => '',
    :address_city     => 'Boulder',
    :address_state    => 'Colorado',
    :address_zip      => '80305'
  },
  {
    :address_line_one => '2735 Iris Ave',
    :address_line_two => '#A',
    :address_city     => 'Boulder',
    :address_state    => 'Colorado',
    :address_zip      => '80304'
  },
  # Campus
  {
    :address_line_one => 'University of Colorado Boulder',
    :address_line_two => 'Math 100',
    :address_city     => 'Boulder',
    :address_state    => 'Colorado',
    :address_zip      => '80309'
  },
  {
    :address_line_one => 'University of Colorado',
    :address_line_two => 'UMC 212',
    :address_city     => 'Boulder',
    :address_state    => 'Colorado',
    :address_zip      => '80309'
  },
  {
    :address_line_one => 'University of Colorado',
    :address_line_two => 'Chem 140',
    :address_city     => 'Boulder',
    :address_state    => 'Colorado',
    :address_zip      => '80309'
  }
]



def random_image
  images = Dir.glob(File.join(Rails.root, "public/images/seed/*.jpeg"))
  File.new images[rand(images.size)]
end

10.times do |index|
  user = User.create! :email => Faker::Internet.email, :password => 'password'

  attributes = {
    :name        => Faker::Company.name,
    :description => Faker::Company.catch_phrase,
    :email       => user.email,
    :image_file  => random_image,
    :locations_attributes => {'0' => locations.pop}
  }

  attributes[:phone] = Faker::PhoneNumber.phone_number if rand(2) == 1

  org = user.organizations.build(attributes)

  org.save

  event = org.events.build

  event.name = Faker::Company.bs
  event.description = Faker::Lorem.sentences(rand(3)+1).join(' ')[0...140]

  event.location = org.location

  start_time      = Time.now + rand(24).hours
  event.starts_at = start_time
  event.ends_at   = start_time + (1 + rand(14)).hours

  event.image_file = random_image
  
  event.save

end


# User.all.each do |user|
#   user.update_attributes! :time_zone => User::DefaultTimeZone
#   user.save!
# end

# Location.all.each do |location|
#   location.calculate_utc_offset!
# end

# Category.categories.each do |category|
#   Category.add!(category)
# end

# Event.index!
# Organization.index!
