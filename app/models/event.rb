class Event < ActiveRecord::Base
  belongs_to :prototype, :class_name => 'Event', :counter_cache => :clone_count
  has_many :clones, :class_name => 'Event', :foreign_key => :prototype_id, :inverse_of => :prototype

  has_many :user_event_joins
  has_many :users, :through => :user_event_joins

  belongs_to :organization
  belongs_to :location
  acts_as_mappable :through => :location

  acts_as_taggable_on :categories

  has_one(:image_context_join, :as => :context, :dependent => :destroy)
  has_one(:image, :through => :image_context_join)

  before_validation(:on => :create) do |event|
    event.uuid ||= App.uuid
  end

  after_save(:on => :create) do |event|
    event.index! rescue nil
  end

  validates_presence_of :uuid
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :starts_at
  validates_presence_of :ends_at

  validates_presence_of :organization
  validates_presence_of :location

  validates_length_of :description, :maximum => 140

# full-text
#
  index do
    search
  end

  def Event.update_clone_counts!
    Event.reset_column_information
    Event.find_in_batches do |batch|
      batch.each do |event|
        Event.update_counters event.id, :clone_count => event.clones.count
      end
    end
  end

  def image_file=(arg)
    image = arg.is_a?(Image) ? arg : Image.for(arg)
    image.save
    self.image = image
  end

  def Event.browse(*args)
    options = Map.extract_options!(args)
    prefix = options[:location] || options[:prefix] || 'colorado'
    prefix = prefix.prefix if prefix.respond_to?(:prefix)
    prefix = Location.absolute_path_for(prefix)

    organization_id = options[:organization_id]

    keywords = args + Array(options[:keywords])
    keywords = Array(keywords).flatten.compact

    page     = options[:page] || 1
    per_page = options[:per_page] || 20
    page     = [Integer(page), 1].max
    per_page = [Integer(per_page), 42].min

    case options[:order].to_s
      when 'name'
        order = 'events.name'
      when 'date'
        order = 'events.starts_at asc'
      else
        order = 'events.starts_at asc'
    end

    if organization_id.blank?
      location = Location.find_by_prefix(prefix)
      unless location
        locations = Location.where('prefix like ?', "#{ prefix }%").order('prefix')
        location = locations.last
      end
      raise "no location for #{ prefix.inspect }" unless location
    else
      organization = Organization.find(organization_id)
      location = organization.location
    end

    date = options[:date]
    dates = nil
    if date
      dates = location.date_range_for(date)
    else
      #default date_range scope will be today
      #TTD - make date_range scope 24 hours ASAP?   russ 1107
      dates = location.date_range_for('today')  
    end

    joins = [:categories, :image, :organization]
    includes = [:categories, :image, :organization]

    results = relation


    if organization_id.blank?
      results = results.search(normalize_search_term("/location/#{ prefix }")) unless prefix.blank?
      results = results.tagged_with(options[:category], :on => 'categories') unless options[:category].blank?
    else
      results = results.search(normalize_search_term("/organization/#{ organization_id }")) unless organization_id.blank?
    end
    results = results.search(keywords.join(' ')) unless keywords.blank?
    results = results.order(order)
    # results = results.joins(joins) # uncommented to fix sorting bug
    results = results.includes(includes)

    if dates
      a = location.time_for(dates.first)
      b = location.time_for(dates.last)
      results = results.where('events.ends_at >= ?', a)
      results = results.where('events.starts_at <= ?', b)
    end

    if Rails.env.production?
      cutoff = Time.now.utc - 1.hours
      cutoff = location.time_for(cutoff) if location
      results = results.where('events.ends_at >= ?', cutoff)
    end

    # results = results.includes(:location).geo_scope(:within => 5, :origin => [40.014781,-105.186989])
    # logger.debug { "----------------- results: #{results.inspect}" }

    begin
      results = results.paginate(:page => page, :per_page => per_page)
    rescue Object => e
      raise unless Rails.env.production?
      Rails.logger.error('BROWSE')
      Rails.logger.error(e)
      result = Event.where('false').paginate(:page => 1, :per_page => 1)
    end
  end

  def Event.time_without_timezone(time)
    time.to_time.strftime(@time_without_timezone_format ||= '%Y-%m-%dT%H:%M:%S')
  end

  def Event.index!
    Event.find_in_batches do |events|
      events.each do |event|
        event.index! rescue next
      end
    end
  end

  def Event.normalize_search_term(term)
    '/' + term.to_s.scan(/[a-zA-Z0-9]+/).join('/').downcase
  end

  def index!
    includes = joins = [:organization]
    #event = Event.where(:id => id).includes(includes).joins(joins).first 
    #raise self.inspect unless event
    event = self

    organization = event.organization
    # venue = event.venue
    location = organization.location

    prefixes = Location.prefixes_for(location.prefix)
    location_search = prefixes.map{|prefix| Event.normalize_search_term("/location/#{ prefix }")}.join(' ')
    category_search =  categories.each.map{|category| Event.normalize_search_term("/category/#{ category.name }")}.join(' ')
    organization_search = Event.normalize_search_term("/organization/#{ organization.id }")

    terms = [
      location_search,
      category_search,
      organization_search,
      event.name, event.description,
      organization.name, organization.description, organization.url, organization.email, organization.phone,
      # venue.name, venue.description, venue.url, venue.email, venue.phone,
      location.country, location.administrative_area_level_1, location.administrative_area_level_2, location.locality
    ]

    search = terms.flatten.compact.join(' ')

    Event.base.update(event.id, :search => search)
  end

  def slug
    parts = []
    parts.push(Slug.for(name))
    if venue and venue.location
      parts.push("location#{ venue.location.prefix }")
    end
    # if category
    #   parts.push("category/#{ Slug.for(category.name) }")
    # end
    if venue and venue.location
      parts.push("date/#{ venue_time.to_date }")
    else
      parts.push("date/#{ starts_at.to_date }")
    end
    parts.join('/')
  end

  def location_time(t = :starts_at)
    case t
      when :starts_at, 'starts_at'
        location.time_for(starts_at)
      when :ends_at, 'ends_at'
        location.time_for(ends_at)
      else
        location.time_for(t)
    end
  end
  alias_method('time_for', 'location_time')
  
  #TTD Original method for time format Paul 
  def venue_time_formatted(*args)
    venue_time(*args).strftime("%A, %b. %e, %Y %l:%M%p (%Z)")
  end
  
  #TTD new methods for time format Paul
  def venue_time_formatted_date(*args)
    venue_time(*args).strftime("%A, %B %e")
  end

  def venue_time_formatted_start(*args)
    venue_time(starts_at).strftime("%l:%M%p")
  end
  
  def venue_time_formatted_end(*args)
    venue_time(ends_at).strftime("%l:%M%p")
  end

  def time_span
    start_time = location_time(starts_at)
    end_time   = location_time(ends_at)

    time = {}
    suffix = ''

    if start_time.strftime('%p') == end_time.strftime('%p')
      time[:start]  = start_time.strftime('%l:%M')
    else
      time[:start]  = start_time.strftime('%l:%M %p')
    end
    time[:end]      = end_time.strftime('%l:%M %p')
    time[:suffix]   = '' #end_time.to_date

    "#{time[:start]} - #{time[:end]} #{time[:suffix]}".strip
  end

  def duration
    (ends_at.to_i - starts_at.to_i).abs
  end

  def repeat!(frequency = :weekly, options = {})
    options.to_options!

    stop = options[:stop] || options[:until] || (ends_at + 3.months)
    stop_date = stop.to_date

    dates = []
    starts_at_date = starts_at.to_date
    starts_at_time = starts_at.strftime('%H:%M:%S')
    delta = ends_at - starts_at
    
    case frequency.to_s
      when /daily/
        until starts_at_date >= stop_date
          starts_at_date += 1
          a = Time.parse("#{ starts_at_date }T#{ starts_at_time }")
          b = a + delta
          dates.push((a .. b))
        end

      when /weekdays/
        until starts_at_date >= stop_date
          starts_at_date += 1
          a = Time.parse("#{ starts_at_date }T#{ starts_at_time }")
          b = a + delta
          dates.push((a .. b))
        end
        dates.delete_if{|r| [6,0].include?(r.first.wday)}

      when /weekends/
        until starts_at_date >= stop_date
          starts_at_date += 1
          a = Time.parse("#{ starts_at_date }T#{ starts_at_time }")
          b = a + delta
          dates.push((a .. b))
        end
        dates.delete_if{|r| ![6,0].include?(r.first.wday)}

      when /weekly/
        until starts_at_date >= stop_date
          starts_at_date += 7
          a = Time.parse("#{ starts_at_date }T#{ starts_at_time }")
          b = a + delta
          dates.push((a .. b))
        end

      when /monthly/
        until starts_at_date >= stop_date
          current_month = starts_at_date.month
          starts_at_date += 1 until starts_at_date.month != current_month
          a = Time.parse("#{ starts_at_date }T#{ starts_at_time }")
          b = a + delta
          dates.push((a .. b))
        end

      else
        raise(ArgumentError, frequency.inspect)
    end

  # ensure we didn't leak past stop date...
  #
    until dates.empty? or dates.last.first < stop
      dates.pop
    end

  # ensure we didn't leak before start date
  #
    while dates.first and dates.first.first <= starts_at
      dates.shift
    end

  # okay - make a bunch-o events!
  #
    prototype = self
    list = []

    transaction do
      dates.each do |pair|
        repeated = Event.new(prototype.attributes)
        repeated.starts_at = pair.first
        repeated.ends_at = pair.last
        repeated.prototype = prototype
        repeated.save!

        repeated.category = prototype.category
        repeated.image = prototype.image
        repeated.organization = prototype.organization
        # repeated.venue = prototype.venue
        repeated.save!

        repeated.index!
        list.push(repeated)
      end
    end

    list
  end

  def featured!(boolean=true)
    featured = Category.for('Featured')

    if boolean.to_s =~ /t/
      categories.push(featured) unless categories.include?(featured)
      true
    else
      categories.delete(featured) if categories.include?(featured)
      false
    end
  ensure
    index!
  end

  def featured?
    categories.any?{|c| c.name.downcase == 'featured' }
  end

  def Event.to_dao(*args)
    remove = %w[search]
    add    = %w[featured? categories image organization location]
    super(*args).reject{|arg| remove.include?(arg)} + add
  end

  # This works, but only for the first object if called on an array.
  # not sure how to fix that, so for now I'll just do the map myself.
  def to_dao(*args)
    options = args.dup.extract_options!
    user = options.delete(:for_user)
    extras = {}
    extras[:trended?] = user.events.include?(self) if user
    super(*options).push(extras)
  end


  scope(:after, lambda{|*args|
    options = args.extract_options!
    after = options[:after] || Date.today
    where('ends_at > ?', after)
  })

  scope(:prototypes, lambda{|*args|
    where('prototype_id is null')
  })

  scope(:featured, lambda{|*args|
    featured = Category.for('Featured')
    joins(:categories).includes(:categories).where('category_id = ?', featured.id)
  })

  scope(:random, lambda{|*args|
    order('random()')
  })
end


# == Schema Information
#
# Table name: events
#
#  id              :integer         not null, primary key
#  uuid            :string(255)
#  organization_id :integer
#  name            :string(255)
#  description     :text
#  starts_at       :datetime
#  ends_at         :datetime
#  repeating       :boolean
#  prototype_id    :integer
#  search          :text
#  created_at      :datetime
#  updated_at      :datetime
#  clone_count     :integer         default(0)
#  repeats         :string(255)
#  users_count     :integer         default(0)
#  location_id     :integer
#

