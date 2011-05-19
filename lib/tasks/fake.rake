STDOUT.sync = true

load File.expand_path('../../../config/boot.rb',  __FILE__)
load File.expand_path('../../../config/environment.rb',  __FILE__)

require 'pp'

namespace(:fake) do

# images
#
  task(:images => :rails_env) do
    fake.images.map! do |i|
      image = Image.where(:image => File.basename(i)).first
      unless image
        image = Image.for(i)
        image.save!
        image
      end
      image
    end
  end

# locations
#
  task(:locations => :rails_env) do
    fake.locations = []
    fake.addresses.each do |address|
      location = Location.where(:address => address).first
      unless location
        location = Location.for(address)
      end
      fake.locations.push(location)
    end
    fake.locations
  end

# data
#
  task(:data => [:rails_env, :images, :locations]) do

    transaction do
    # build some users
    #
      users = []
      emails = %w( a b c ).map{|name| "#{ name }@#{ App.domain }"}

      emails.each do |email|
        user = User.where(:email => email).first
        user ||= User.create!(:email => email, :password => 'password')
        users.push(user)
      end
      
    # build some organizations
    #
      organizations = []
      organization_names = ('a' .. 'z').map{|alpha| "organization-#{ alpha }"}.first(10)

      users.each do |user|
        api = user.api

        organization_names.each do |name|
          organization = user.organizations.where(:name => name).first
          if organization
            organizations.push(organization)
            next
          end

          attributes = Map.new(:name => name)
          attributes[:name] = name
          attributes[:description] = fake.paragraphs.sort_by{ rand }.first 
          attributes[:email] = user.email
          attributes[:phone] = fake.phone_numbers.sort_by{ rand }.first
          attributes[:url] = fake.urls.sort_by{ rand }.first 
          attributes[:address] = fake.addresses.sort_by{ rand }.first

          organization = Organization.create!(attributes)
          organization.users.add(user)

          organization.category = fake.categories.sort_by{ rand }.first
          organization.image = fake.images.sort_by{ rand }.first
          organization.location = fake.locations.sort_by{ rand }.first
          organization.build_default_venue!
          organization.set_status!(fake.sentences.sort_by{ rand }.first)

          raise organization.errors.inspect unless organization.valid?

          organizations.push(organization)
        end
      end

    # build some events
    #
      events = []
      event_names = ('a' .. 'z').map{|alpha| "event-#{ alpha }"}.first(10)

      organizations.each do |organization|
        event_names.each do |name|
          event = organization.events.where(:name => name).first
          if event
            events.push(event)
            next
          end

          category = fake.categories.sort_by{ rand }.first
          image = fake.images.sort_by{ rand }.first

          attributes = Hash.new(:name => name)
          attributes[:name] = name
          attributes[:description] = fake.paragraphs.sort_by{ rand }.first 
          attributes[:starts_at] = Time.now + rand(42000)
          attributes[:ends_at] = Time.now + rand(42000)
          attributes[:all_day] = rand > 0.42 ? true : false
          attributes[:repeating] = false

          #attributes[:category] = category
          #attributes[:venue] = organization.venue
          #attributes[:image] = open image

          event = organization.events.create!(attributes)

          event.category = fake.categories.sort_by{ rand }.first
          event.image = fake.images.sort_by{ rand }.first
          event.venue = organization.venue

          #pp event
          #pp event.category
          #pp event.image
          #pp event.venue
          #pp event.venue.location
          #abort

          raise event.inspect unless event.valid?

          y event.attributes
        end
      end

    # full-text index everything!
    #
      Event.index! rescue nil
      Organization.index! rescue nil
    end
  end


  def fake
    return @fake if defined?(@fake)
    @fake = Map.new

    fake.emails =
      %w( a b c ).map{|name| "#{ name }@#{ App.domain }"}

    fake.paragraphs =
      Array.new(10).map{ Faker::Lorem.paragraph }

    3.times do
      paragraph = fake.paragraphs.sort_by{ rand }.first
      url = 'http://'+Faker::Internet.domain_name
      edited = paragraph.split(/\n/)
      edited = [url, *edited].sort_by{ rand }.join("\n")
      paragraph.replace(edited)
    end

    fake.sentences =
      Array.new(10).map{ Faker::Lorem.sentence }

    3.times do
      sentence = fake.sentences.sort_by{ rand }.first
      url = 'http://'+Faker::Internet.domain_name
      edited = sentence.split(/\s/)
      edited = [url, *edited].sort_by{ rand }.join(' ')
      sentence.replace(edited)
    end

    fake.urls =
      Array.new(10).map{ "http://" + Faker::Internet.domain_name }

    fake.addresses = [
      "2030 17th street, boulder, co, 80302",
      "3055 18th street, boulder, co, 80304",
      "3057 18th street, boulder, co, 80304",
      "240 North Independence, palmer, alaska, 99645",
      "denver, co",
      "lakewood, co",
      "casper, wy",
      "la, california",
      "san franciso, ca",
      'anchorage, ak'
    ]

    fake.phone_numbers =
      Array.new(10).map{ Faker::PhoneNumber.phone_number }

    fake.categories =
      Category.list

    fake.images =
      Dir.glob(File.join(Rails.root, 'public/images/fake/*')).map do |image|
        image
      end

    fake
  end
end

