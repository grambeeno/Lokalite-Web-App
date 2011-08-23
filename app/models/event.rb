class Event < ActiveRecord::Base
  include PgSearch

  belongs_to :prototype, :class_name => 'Event', :counter_cache => :clone_count
  has_many :clones, :class_name => 'Event', :foreign_key => :prototype_id, :inverse_of => :prototype

  has_many :user_event_joins
  has_many :users, :through => :user_event_joins

  belongs_to :organization
  belongs_to :image, :class_name => 'EventImage'
  belongs_to :location, :include => :geocoding

  acts_as_geocodable :through => :location

  acts_as_taggable_on :categories

  def first_category
    category_list.split(', ').first.first
  end
  def second_category
    if categories.size > 1
      category_list.split(', ').first.last
    end
  end

  before_validation(:on => :create) do |event|
    event.uuid ||= App.uuid
  end

  validates_presence_of :uuid
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :starts_at
  validates_presence_of :ends_at

  validates_presence_of :organization
  validates_presence_of :location
  validates_presence_of :image

  validates_length_of :description, :maximum => 140

  accepts_nested_attributes_for :location
  accepts_nested_attributes_for :image
  validates_associated :image

  pg_search_scope :search, :against => [[:name, 'A'], [:description, 'C']], :associated_against => {:organization => [[:name, 'B']]}

  scope :by_date, order('starts_at')

  scope(:after, lambda{|time|
    where('ends_at > ?', time)
  })
  scope :upcoming, by_date().after(Time.now)

  scope(:prototypes, lambda{|*args|
    where('prototype_id is null')
  })

  scope(:featured, lambda{|*args|
    joins(:categories).includes(:categories).tagged_with('featured', :on => :categories)
  })

  scope(:random, lambda{|*args|
    order('random()')
  })


  scope :trending, upcoming.includes(:organization).order('users_count DESC, starts_at')

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
    # location_string = options[:location] || 'Boulder, CO'

    organization_id = options[:organization_id]

    keywords = args + Array(options[:keywords])
    keywords = Array(keywords).flatten.compact

    page     = options[:page] || 1
    per_page = options[:per_page] || 20
    page     = [Integer(page), 1].max
    per_page = [Integer(per_page), 42].min

    start_time = options[:after] || Time.now

    results = Event.after(start_time)

    if organization_id.blank?
      results = results.tagged_with(options[:category], :on => 'categories') unless options[:category].blank?
    else
      results = results.where(:organization_id => organization_id)
    end
    results = results.search(keywords.join(' ')) unless keywords.blank?
    # results = results.joins(:categories, :image, :organization, :location) # uncommented to fix sorting bug

    results = results.includes(:categories, :location, :image, :organization => [:categories, :locations])

    origin  = options[:origin].humanize
    within  = options[:within] || 20
    results = results.origin(origin, :within => within) if origin.present?

    if options[:order] == 'distance' && origin.present?
      results = results.near
    elsif options[:order] == 'trending'
      results = results.trending
    elsif options[:order] == 'name'
      results = results.order('events.name ASC')
    else
      results = results.order('events.starts_at ASC')
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

  def Event.normalize_search_term(term)
    '/' + term.to_s.scan(/[a-zA-Z0-9]+/).join('/').downcase
  end

  def slug
    Slug.for(name)
  end

  # def location_time(t = :starts_at)
  #   case t
  #     when :starts_at, 'starts_at'
  #       location.time_for(starts_at)
  #     when :ends_at, 'ends_at'
  #       location.time_for(ends_at)
  #     else
  #       location.time_for(t)
  #   end
  # end
  # alias_method('time_for', 'location_time')

  # #TTD Original method for time format Paul
  # def venue_time_formatted(*args)
  #   venue_time(*args).strftime("%A, %b. %e, %Y %l:%M%p (%Z)")
  # end
  #
  # #TTD new methods for time format Paul
  # def venue_time_formatted_date(*args)
  #   venue_time(*args).strftime("%A, %B %e")
  # end
  #
  # def venue_time_formatted_start(*args)
  #   venue_time(starts_at).strftime("%l:%M%p")
  # end
  #
  # def venue_time_formatted_end(*args)
  #   venue_time(ends_at).strftime("%l:%M%p")
  # end

  # def time_span
  #   start_time = location_time(starts_at)
  #   end_time   = location_time(ends_at)
  #
  #   time = {}
  #   suffix = ''
  #
  #   if start_time.strftime('%p') == end_time.strftime('%p')
  #     time[:start]  = start_time.strftime('%l:%M')
  #   else
  #     time[:start]  = start_time.strftime('%l:%M %p')
  #   end
  #   time[:end]      = end_time.strftime('%l:%M %p')
  #   time[:suffix]   = '' #end_time.to_date
  #
  #   "#{time[:start]} - #{time[:end]} #{time[:suffix]}".strip
  # end

  def duration
    (ends_at.to_i - starts_at.to_i).abs
  end

  # def repeat!(frequency = :weekly, options = {})
  #   options.to_options!

  #   stop = options[:stop] || options[:until] || (ends_at + 3.months)
  #   stop_date = stop.to_date

  #   dates = []
  #   starts_at_date = starts_at.to_date
  #   starts_at_time = starts_at.strftime('%H:%M:%S')
  #   delta = ends_at - starts_at
  #
  #   case frequency.to_s
  #     when /daily/
  #       until starts_at_date >= stop_date
  #         starts_at_date += 1
  #         a = Time.parse("#{ starts_at_date }T#{ starts_at_time }")
  #         b = a + delta
  #         dates.push((a .. b))
  #       end

  #     when /weekdays/
  #       until starts_at_date >= stop_date
  #         starts_at_date += 1
  #         a = Time.parse("#{ starts_at_date }T#{ starts_at_time }")
  #         b = a + delta
  #         dates.push((a .. b))
  #       end
  #       dates.delete_if{|r| [6,0].include?(r.first.wday)}

  #     when /weekends/
  #       until starts_at_date >= stop_date
  #         starts_at_date += 1
  #         a = Time.parse("#{ starts_at_date }T#{ starts_at_time }")
  #         b = a + delta
  #         dates.push((a .. b))
  #       end
  #       dates.delete_if{|r| ![6,0].include?(r.first.wday)}

  #     when /weekly/
  #       until starts_at_date >= stop_date
  #         starts_at_date += 7
  #         a = Time.parse("#{ starts_at_date }T#{ starts_at_time }")
  #         b = a + delta
  #         dates.push((a .. b))
  #       end

  #     when /monthly/
  #       until starts_at_date >= stop_date
  #         current_month = starts_at_date.month
  #         starts_at_date += 1 until starts_at_date.month != current_month
  #         a = Time.parse("#{ starts_at_date }T#{ starts_at_time }")
  #         b = a + delta
  #         dates.push((a .. b))
  #       end

  #     else
  #       raise(ArgumentError, frequency.inspect)
  #   end

  # # ensure we didn't leak past stop date...
  # #
  #   until dates.empty? or dates.last.first < stop
  #     dates.pop
  #   end

  # # ensure we didn't leak before start date
  # #
  #   while dates.first and dates.first.first <= starts_at
  #     dates.shift
  #   end

  # # okay - make a bunch-o events!
  # #
  #   prototype = self
  #   list = []

  #   transaction do
  #     dates.each do |pair|
  #       repeated = Event.new(prototype.attributes)
  #       repeated.starts_at = pair.first
  #       repeated.ends_at = pair.last
  #       repeated.prototype = prototype
  #       repeated.save!

  #       repeated.category = prototype.category
  #       repeated.image = prototype.image
  #       repeated.organization = prototype.organization
  #       # repeated.venue = prototype.venue
  #       repeated.save!

  #       repeated.index!
  #       list.push(repeated)
  #     end
  #   end

  #   list
  # end

  def clone?
    prototype_id.present?
  end

  def clone_with_date(date)
    offset = (date.to_date - starts_at.to_date).days
    cleaned_attributes = attributes.reject{|key, value| %w[id clone_count users_count].include?(key) }
    clone  = Event.new(cleaned_attributes)
    clone.starts_at = starts_at + offset
    clone.ends_at   = ends_at + offset
    clone.prototype = self
    clone.save
  end

  # def featured!(boolean=true)
  #   featured = Category.for('Featured')

  #   if boolean.to_s =~ /t/
  #     categories.push(featured) unless categories.include?(featured)
  #     true
  #   else
  #     categories.delete(featured) if categories.include?(featured)
  #     false
  #   end
  # ensure
  #   index!
  # end

  def featured?
    categories.any?{|c| c.name.downcase == 'featured' }
  end

  # the following are needed for to_dao
  def image_full
    image.image_url
  end
  def image_large
    image.image_url(:large)
  end
  def image_medium
    image.image_url(:medium)
  end
  def image_small
    image.image_url(:small)
  end
  def image_thumb
    image.image_url(:thumb)
  end

  def Event.to_dao(*args)
    remove = %w[]
    add    = %w[featured? categories organization location image_thumb image_small image_medium image_large image_full]
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
end




# == Schema Information
#
# Table name: events
#
#  id              :integer         not null, primary key
#  uuid            :string(255)
#  name            :string(255)
#  description     :string(255)
#  starts_at       :datetime
#  ends_at         :datetime
#  repeating       :boolean
#  prototype_id    :integer
#  organization_id :integer
#  image_id        :integer
#  location_id     :integer
#  created_at      :datetime
#  updated_at      :datetime
#  clone_count     :integer         default(0)
#  repeats         :string(255)
#  users_count     :integer         default(0)
#

