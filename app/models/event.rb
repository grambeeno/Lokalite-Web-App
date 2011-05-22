class Event < ActiveRecord::Base
# prototype
#
  belongs_to(:prototype, :class_name => 'Event', :counter_cache => :clone_count)
  has_many(:clones, :class_name => 'Event', :foreign_key => :prototype_id, :inverse_of => :prototype)

# organization relationships
#
  belongs_to(:organization)

# category relationships
#
  has_one(:category_context_join, :as => :context, :dependent => :destroy, :conditions => {:kind => 'primary'})
  has_one(:category, :through => :category_context_join)
  has_many(:category_context_joins, :as => :context, :dependent => :destroy)
  has_many(:categories, :through => :category_context_joins)

  #has_one(:category_context_join, :as => :context, :dependent => :destroy)
  #has_one(:category, :through => :category_context_join, :conditions => {'category_context_joins.kind' => 'primary'})
  #has_one(:category_context_join, :as => :context, :dependent => :destroy, :conditions => {'category_context_joins.kind' => 'primary'})


# image relationships
#
  has_one(:image_context_join, :as => :context, :dependent => :destroy)
  has_one(:image, :through => :image_context_join)

# venue relationships
#
  has_one(:venue_context_join, :as => :context, :dependent => :destroy)
  has_one(:venue, :through => :venue_context_join, :include => :location)

# lifecycle hooks
#
  before_validation(:on => :create) do |event|
    event.uuid ||= App.uuid
  end

  after_save(:on => :create) do |event|
    event.index! rescue nil
  end

# validations
#
  validates_presence_of :uuid
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :starts_at
  validates_presence_of :ends_at
  validates_inclusion_of :all_day, :in => [true, false]

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

  def Event.browse(*args)
    options = Map.extract_options!(args)

    prefix = options[:location] || options[:prefix]
    prefix = prefix.prefix if prefix.respond_to?(:prefix)
    prefix = Location.absolute_path_for(prefix)

    category = options[:category]
    category = category.name if category.respond_to?(:name)
    category = Slug.for(category)

    organization = options[:organization]
    organization = organization.id if organization.is_a?(Organization) 

    keywords = args + Array(options[:keywords])
    keywords = Array(keywords).flatten.compact

    page = options[:page] || 1
    per_page = options[:per_page] || 20 
    page = [Integer(page), 1].max
    per_page = [Integer(per_page), 42].min

    ### per_page = 3 if Rails.env.development?

    order = options[:order]
    order, joins =
      case order.to_s
        when 'name'
          ['events.name', []]
        when 'date'
          ['events.starts_at', []]
        when 'category'
          ['categories.name', [:categories]]
        when 'venue'
          ['venues.name', [:venue]]
        when 'location'
          ['locations.prefix', [{:venue => :location}]]
        else
          ['events.starts_at asc', []]
      end

    if organization.blank?
      location = Location.find_by_prefix(prefix)
      unless location
        locations = Location.where('prefix like ?', "#{ prefix }%").order('prefix')
        location = locations.last
      end
      raise "no location for #{ prefix.inspect }" unless location
    end

    date = options[:date]
    dates = nil
    if date
      dates = location.date_range_for(date)
    end

    # Not sure why all these joins were necessary;
    # It should be sufficient to join only tables needed for sorting
    # joins = [:categories, :image, :venue, {:venue => :location}]

    includes = [:categories, :image, :venue]

    results = relation
    if organization.blank?
      results = results.search(normalize_search_term("/location/#{ prefix }")) unless prefix.blank?
      results = results.search(normalize_search_term("/category/#{ category }")) unless category.blank?
    else
      results = results.search(normalize_search_term("/organization/#{ organization }")) unless organization.blank?
    end
    results = results.search(keywords.join(' ')) unless keywords.blank?
    results = results.order(order)
    results = results.joins(joins) # uncommented to fix sorting bug
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
    includes = joins = [:organization, {:venue => :location}]
    #event = Event.where(:id => id).includes(includes).joins(joins).first 
    #raise self.inspect unless event
    event = self

    organization = event.organization
    venue = event.venue
    location = venue.location

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
      venue.name, venue.description, venue.url, venue.email, venue.phone,
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
    if category
      parts.push("category/#{ Slug.for(category.name) }")
    end
    if venue and venue.location
      parts.push("date/#{ venue_time.to_date }")
    else
      parts.push("date/#{ starts_at.to_date }")
    end
    parts.join('/')
  end

  def venue_time(t = :starts_at)
    case t
      when :starts_at, 'starts_at'
        venue.time_for(starts_at)
      when :ends_at, 'ends_at'
        venue.time_for(ends_at)
      else
        venue.time_for(t)
    end
  end
  alias_method('time_for', 'venue_time')

  def venue_time_formatted(*args)
    venue_time(*args).strftime("%A, %b. %e, %Y %l:%M%p (%Z)")
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
        repeated.venue = prototype.venue
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
    featured = Category.for('Featured')
    categories.include?(featured)
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
