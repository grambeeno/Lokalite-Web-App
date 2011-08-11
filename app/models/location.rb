class Location < ActiveRecord::Base
  # include PgSearch
  # pg_search_scope :search, :against => [:name, :address_line_one]

  acts_as_geocodable :normalize_address => true
  validates_as_geocodable :precision => 'address'

  def formatted_address(line_break = ', ')
    "#{street}#{line_break}#{locality}, #{region} #{postal_code}"
  end

  belongs_to :organization
  has_many :events

  before_validation(:on => :create) do |location|
    location.uuid ||= App.uuid
  end

  validates_presence_of :uuid
  # validates_presence_of :country

  # validate :validate!
  # def validate!
  #   if data
  #     formatted_addresses = Location.formatted_addresses_for(data)
  #     if formatted_addresses.size > 1
  #       message = "ambiguous location: " + formatted_addresses.join(' | ')
  #       errors.add(:base, message)
  #     end
  #   end
  # end

  # before_validation :verify_and_normalize_user_given_address
  # attr_accessor :address_line_one, :address_line_two, :address_city, :address_state, :address_zip

  # def state
  #   administrative_area_level_1
  # end
  # def county
  #   administrative_area_level_2
  # end
  # def city
  #   locality
  # end
  def latitude
    geocode.latitude
  end

  def longitude
    geocode.longitude
  end

  def coordinates
    [latitude, longitude].join(',')
  end

  def Location.to_dao(*args)
    remove = %w[]
    add    = %w[formatted_address latitude longitude]
    super(*args).reject{|arg| remove.include?(arg)} + add
  end


  # def verify_and_normalize_user_given_address
  #   suffix  = [address_state, address_zip].compact.join(' ').strip
  #   address = [address_line_one, address_line_two, address_city, suffix].compact.reject{|e| e.empty? }.join(', ').strip

  #   return self unless address.present?

  #   response = GGeocode(address)
  #   unless response
  #     errors.add(:base, "#{ address.inspect } not found")
  #     return false
  #   end

  #   self.json = response.json

  #   persist_data_from_json!
  # end

  # def set_address_components_for_editing
  #   self.address_line_one = "#{extract_address_component('street_number')} #{extract_address_component('route')}"
  #   self.address_line_two = extract_address_component('subpremise')
  #   self.address_city     = city
  #   self.address_state    = state
  #   self.address_zip      = postal_code
  #   self
  # end


  # def address_json
  #   # validation fails elsewhere if there are multiple results, just take the first
  #   data['results'].first
  # end

  # def data
  #   @data ||= (
  #     if json
  #       JSON.parse(json)
  #     end
  #   )
  # end

  # def json=(json)
  #   json_will_change!
  #   write_attribute(:json, json)
  # ensure
  #   @data = json ? JSON.parse(json) : nil
  # end

  # def data=(data)
  #   @data = data
  #   json_will_change!
  #   write_attribute(:json, data ? data.to_json : nil)
  #   @data
  # end

  # def persist_data_from_json!
  #   begin
  #     @address_components = address_json['address_components']
  #     location            = address_json['geometry']['location']
  #   rescue NoMethodError
  #     errors.add(:base, "Results from Google Maps could not be parsed.")
  #     return false
  #   end

  #   parsed = {}

  #   for field in %w[country administrative_area_level_1 administrative_area_level_2 locality postal_code]
  #     parsed[field] = extract_address_component(field)
  #   end

  #   prefix = Location.absolute_path_for(parsed['administrative_area_level_1'], parsed['locality'])

  #   parsed['prefix']            = prefix
  #   parsed['formatted_address'] = address_json['formatted_address']
  #   parsed['lat']               = location['lat']
  #   parsed['lng']               = location['lng']

  #   return nil if parsed.empty?
  #   self.attributes = parsed
  #   calculate_utc_offset!
  #   self
  # end

  # def extract_address_component(name)
  #   begin
  #     @address_components ||= data['results'].first['address_components']
  #     @address_components.find{|component| component['types'].include?(name) }['long_name']
  #   rescue NoMethodError
  #     nil
  #   end
  # end

  # def Location.pinpoint(string)
  #   data = GGeocode(string)
  #   Location.formatted_addresses_for(data)
  # end

  # def Location.pinpoint?(string)
  #   Location.pinpoint(string).size == 1
  # end


  # def Location.formatted_addresses_for(data)
  #   return [] unless data
  #   results = data['results']
  #   return [] unless results
  #   results.map{|result| result['formatted_address']}
  # end

  # def Location.absolute_path_for(*args)
  #   return '/' if args.empty?
  #   args = Util.absolute_path_for(*args).split('/')
  #   args.map!{|arg| Slug.for(arg)}
  #   Util.absolute_path_for(*args)
  # end

  # def Location.prefixes
  #   Location.select('distinct prefix').order('prefix').select('prefix').map{|loc| loc.prefix}
  # end

  # def Location.list
  #   items = {}
  #   prefixes.each do |prefix|
  #     loop do
  #       items[prefix] ||= prefix
  #       prefix = File.dirname(prefix)
  #       break if prefix=='/'
  #     end
  #   end
  #   items.keys.sort
  # end

  # def Location.prefixes_for(prefix)
  #   prefixes = []
  #   prefix = Location.absolute_path_for(prefix)
  #   loop do
  #     prefixes.unshift(prefix)
  #     prefix = File.dirname(prefix)
  #     break if prefix=='/'
  #   end
  #   prefixes
  # end


# TODO - this doesn't *quite* work
#
  # def Location.ensure_parents_exist!(location)
  #   prefix = location.prefix
  #   parts = [location.administrative_area_level_1, location.locality].compact
  #   parts.pop

  #   locations = []

  #   until parts.empty?
  #     address = parts.join(', ')
  #     parts.pop
  #     location = Location.locate(address)
  #     break unless(location and location.valid?)
  #     next unless prefix.index(location.prefix) == 0
  #     location.save! if location.new_record?
  #     locations.push(location)
  #   end

  #   locations
  # end

  # def ensure_parents_exist!
  #   Location.ensure_parents_exist!(location=self)
  # end

  # after_save(:on => :create) do |location|
  #   location.ensure_parents_exist!
  # end

  # scope(:prefixed_by,
  #   lambda do |prefix|
  #     prefix = Location.absolute_path_for(prefix)
  #     stem = prefix + '/%'
  #     where('(prefix = ? or prefix like ?)', prefix, stem)
  #   end
  # )

  # def Location.prefix?(prefix)
  #   prefix = Location.absolute_path_for(prefix)
  #   stem = prefix + '/%'
  #   where('(prefix = ? or prefix like ?)', prefix, stem).count != 0
  # end

  # def to_s
  #   prefix
  # end

  # def basename
  #   File.basename(prefix)
  # end


  # def same
  #   Location.new(
  #     :lat => lat,
  #     :lng => lng,
  #     :prefix => prefix,
  #     :address => address,
  #     :json => json
  #   )
  # end

  def calculate_utc_offset!
    n = 42
    begin
      tz = EarthTools.timezone({:latitude => latitude, :longitude => longitude})

      localtime = Time.parse(tz.localtime)
      utctime = Time.parse(tz.utctime)

      a = Float(tz.offset)
      b = (localtime - utctime) / 3600.0

      raise tz.inspect unless(b == a)

      utc_offset = (localtime - utctime)

      self.utc_offset = utc_offset
    rescue Object => e
      raise if Rails.env.development?
      n -= 1
      raise if n <= 0
      Rails.logger.error(e)
      sleep(rand)
      retry
    end
  end

  def time_zone(&block)
    if block
      Time.use_zone(time_zone){ block.call(time_zone) }
    else
      @time_zone ||= ActiveSupport::TimeZone[ utc_offset ]
    end
  end

  def time
    Time.use_zone( time_zone ) do
      Time.zone.now
    end
  end
  alias_method('now', 'time')

  def time_for(t)
    t =
      case t
        when Time, Date
          t.to_time.to_s
        else
          t.to_s
      end
    time_zone.parse(t.to_s)
  end

  def date_for(d)
    time_for(d).to_date
  end

  def date
    date_for(Date.today)
  end

  def Location.date_range_for(location, date_range_name)
    today = Date.today
    date_a = nil
    date_b = nil
    name = nil

    case date_range_name.to_s
      when 'today'
        name = 'today'
        date_a = location.time_for(today)
        date_b = date_a + 24.hours
      when 'tomorrow'
        name = 'tomorrow'
        date_a = location.time_for(today + 1)
        date_b = date_a + 24.hours
      when 'this_weekend', 'weekend'
        name = 'this_weekend'
        day = location.time_for(today)
        until day.strftime('%a') == 'Sat'
          day += 1.day
        end
        date_a = location.time_for(day)
        date_b = date_a + 2.days
      when 'this_week', 'week'
        name = 'this_week'
        date_a = location.time_for(today)
        date_b = date_a + 1.week
      when 'this_month', 'month'
        name = 'this_month'
        date_a = location.time_for(today)
        date_b = date_a + 1.month
      when 'this_year', 'year'
        name = 'this_year'
        date_a = location.time_for(today)
        date_b = date_a + 1.year
      when 'all'
        name = 'all'
        date_a = Time.starts_at
        date_b = Time.ends_at
    end

    DateRange.new(date_a, date_b, name)
  end

  def date_range_for(date_range_name)
    Location.date_range_for(location=self, date_range_name)
  end

  def Location.date_range_name_for(location, date)
    #remove ALL as a possible query value - russ 1107
    #ranges = %w( today tomorrow this_weekend this_week this_month this_year all).map{|name| date_range_for(location, name)}
    ranges = %w( today tomorrow this_weekend this_week this_month this_year).map{|name| date_range_for(location, name)}
    time = date.to_time
    range = ranges.detect{|r| r.include?(time)}
    range.name
  end

  def date_range_name_for(date)
    Location.date_range_name_for(location=self, date)
  end

  class DateRange < ::Range
    attr_accessor :name

    def initialize(a, b, name)
      a ||= Time.starts_at
      b ||= Time.ends_at
      name ||= 'All'
      super(a, b)
      self.name = Slug.for(name)
    end
  end

=begin
  http://www.earthtools.org/timezone/40.71417/-74.00639

  Time.parse('2011-02-12 17:28:10Z') - Time.parse('2011-02-12 22:28:10Z') #=> -18000.0

=end
  def utc_offset
    -18000
  end
end




# == Schema Information
#
# Table name: locations
#
#  id              :integer         not null, primary key
#  uuid            :string(255)
#  name            :string(255)
#  street          :string(255)
#  locality        :string(255)
#  region          :string(255)
#  postal_code     :string(255)
#  country         :string(255)
#  organization_id :integer
#  utc_offset      :float
#  created_at      :datetime
#  updated_at      :datetime
#

