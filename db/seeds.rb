# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

User.destroy_all
Organization.destroy_all
Location.destroy_all
EventImage.destroy_all
Event.destroy_all


User.create! :email => 'admin@lokalite.com', :password => 'password'
User.create! :email => 'lokalite@lokalite.com', :password => 'LokalBluePedia!123'
User.create! :email => 'zef@madebykiwi.com', :password => 'password'

locations = [
  {
    :street      => '417 Harvard Ln.',
    :locality    => 'Boulder',
    :region      => 'Colorado',
    :postal_code => '80305'
    },
  {
    :street      => '1226 Pennsylvania Ave. suite 2',
    :locality    => 'Boulder',
    :region      => 'Colorado',
    :postal_code => '80302'
  },
  {
    :street      => '1320 Pearl St. Suite 110',
    :locality    => 'Boulder',
    :region      => 'Colorado',
    :postal_code => '80302'
  },
  {
    :street      => '2218 Edgewood Dr.',
    :locality    => 'Boulder',
    :region      => 'Colorado',
    :postal_code => '80302'
  },
  {
    :street      => '454 Arapahoe Ave. appt. #3',
    :locality    => 'Boulder',
    :region      => 'Colorado',
    :postal_code => '80302'
  },
  {
    :street      => '1145 Pennsylvania Ave #5',
    :locality    => 'Boulder',
    :region      => 'Colorado',
    :postal_code => '80302'
  },
  {
    :street      => '3000 Center Green Dr Suite 140',
    :locality    => 'Boulder',
    :region      => 'Colorado',
    :postal_code => '80301'
  },
  {
    :street      => ' 3198 Broadway',
    :locality    => 'Boulder',
    :region      => 'Colorado',
    :postal_code => '80304'
  },
  {
    :street      => '3600 Table Mesa Drive',
    :locality    => 'Boulder',
    :region      => 'Colorado',
    :postal_code => '80305'
  },
  {
    :street      => '2735 Iris Ave #A',
    :locality    => 'Boulder',
    :region      => 'Colorado',
    :postal_code => '80304'
  },
  # Campus
  {
    :street      => 'University of Colorado Boulder, Math 100',
    :locality    => 'Boulder',
    :region      => 'Colorado',
    :postal_code => '80309'
  },
  {
    :street      => 'University of Colorado University Memorial Center 212',
    :locality    => 'Boulder',
    :region      => 'Colorado',
    :postal_code => '80309'
  },
  {
    :street      => 'University of Colorado Chem 140',
    :locality    => 'Boulder',
    :region      => 'Colorado',
    :postal_code => '80309'
  }
]


class Array
  def rand
    self[super(self.length)]
  end
end

def random_image
  images = Dir.glob(File.join(Rails.root, "public/images/seed/*.jpeg"))
  File.new images[rand(images.size)]
end

10.times do |index|
  user = User.create! :email => Faker::Internet.email, :password => 'password'

  location = locations.rand
  org_name = Faker::Company.name
  location[:name] = org_name

  attributes = {
    :name                 => org_name,
    :description          => Faker::Company.catch_phrase,
    :email                => user.email,
    :image                => random_image,
    :locations_attributes => {'0'                         => location},
    :category_list        => ORGANIZATION_CATEGORIES.rand
  }

  attributes[:phone] = Faker::PhoneNumber.phone_number if rand(2) == 1

  org = Organization.new(attributes)
  org.save

  # puts "Address   #{location[:street]}"
  # puts "Formatted #{org.location.formatted_address}"
  # puts '---------------------------------------------'

  user.organizations << org

  (rand(5) + 1).times do
    event = org.events.build

    event.name = Faker::Company.bs
    event.description = Faker::Lorem.sentences(rand(3)+1).join(' ')[0...140]

    event.location = org.location

    start_time      = Time.now + rand(24).hours
    event.starts_at = start_time
    event.ends_at   = start_time + (1 + rand(14)).hours

    event.image_attributes = {:image => random_image}

    categories = []
    categories << EVENT_CATEGORIES.rand
    categories << EVENT_CATEGORIES.rand if rand(4) == 1
    categories << 'Featured' if rand(4) == 1

    event.category_list = categories.join(', ')

    event.save
  end
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
