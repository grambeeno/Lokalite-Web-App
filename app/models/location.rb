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
  validates_presence_of :name

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

