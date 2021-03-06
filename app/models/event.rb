class Event < ActiveRecord::Base
  include PgSearch

  belongs_to :prototype, :class_name => 'Event', :counter_cache => :clone_count
  has_many :clones, :class_name => 'Event', :foreign_key => :prototype_id, :inverse_of => :prototype, :dependent => :destroy

  has_many :user_event_joins
  has_many :users, :through => :user_event_joins
  has_many :event_features

  belongs_to :created_by, :class_name => 'User'

  belongs_to :organization, :touch => true
  belongs_to :image, :class_name => 'EventImage'
  belongs_to :location, :include => :geocoding

  acts_as_geocodable :through => :location

  acts_as_taggable_on :categories

  def first_category
    normal_categories.first
  end
  def second_category
    if normal_categories.size > 1
      normal_categories.last
    end
  end

  def normal_categories
    categories.reject{|c| c.name == 'Featured'}
  end

  validate :category_is_present
  def category_is_present
    errors.add_to_base "Category can't be blank" unless category_list.present?
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

  # We would use:
  # validates_length_of :description, :maximum => 140
  # but it counts line breaks as 2 chars. Need to do it ourselves.
  validate :check_description_length
  def check_description_length
    return if description.blank?
    stripped = description.gsub /\r\n/, ' '
    if stripped.length > 200
      errors.add(:description, 'is too long (maximum is 200 characters)')
    end
  end

  accepts_nested_attributes_for :location
  accepts_nested_attributes_for :image
  validates_associated :image

  # If we want to search for attributes inside the event organization, we need to
  # pg_search_scope :search, :against => [[:name, 'A'], [:description, 'C']], :associated_against => {:organization => [[:name, 'B']]}
  pg_search_scope :search, :against => [[:name, 'A'], [:description, 'C']], :associated_against => { :organization => [[:name, 'B']]}

  scope :approved, where(:approved => true)
  scope :not_approved, where(:approved => false)
  scope :by_date, order('starts_at')

  scope(:after, lambda{|time|
    where('ends_at > ?', time)
  })
  scope(:before, lambda{|time|
    where('starts_at < ?', time)
  })
  scope :upcoming, by_date().after(Time.now) 
  scope :upcoming_featured, order('event_features.date').after(Time.now)

  scope :repeating,  where(:repeating => true)
  scope :one_time,   where(:repeating => false)
  scope :prototypes, where(:prototype_id => nil)

  scope(:featured_on, lambda{|date|
    includes(:event_features).where(['event_features.date = ?', date]).order('event_features.slot')
  })

  scope(:featured_between, lambda{|date|
    includes(:event_features).where(['event_features.date >= ?', date - 31.days]).where(['event_features.date <= ?', date]).order('event_features.date')
  })

  scope(:random, lambda{|*args|
    order('random()')
  })
  scope :popular, order('trend_weight DESC').upcoming.includes(:organization).limit(12)

  def self.next_featured_in_slot(slot)
    upcoming_featured.includes(:event_features).
      where(['event_features.slot = ?', slot]).
      where(['event_features.date >= ? AND event_features.date <= ?', Date.today, Date.tomorrow]).
      order('event_features.date').
      limit(1).first
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

    page     = options[:page] || 1
    per_page = options[:per_page] || 24
    page     = [Integer(page), 1].max
    per_page = [Integer(per_page)].min

    start_time = if options[:after].present?
      begin
        # experienced a specific format that would convert with to_time, but it's not actually what we wanted
        # we raise manually so it falls to Chronic.parse
        raise if options[:after].match(/\d{2}-\d{2}-\d{4}/)
        options[:after].to_time
      rescue
        string = URI.decode(options[:after]).gsub('+', ' ').humanize
        Chronic.parse(string)
      end
    elsif options[:view_type] == 'map'
      Time.zone.now - 6.hours
    else
      Time.zone.now
    end

    latest_start = if options[:before]
      begin
        options[:before].to_time
      rescue
        string = URI.decode(options[:before]).gsub('+', ' ').humanize
        Chronic.parse(string)
      end
    elsif options[:view_type] == 'map'
      Time.zone.now + 18.hours
    end

    results = Event.approved.after(start_time)
    results = results.before(latest_start) if latest_start 

    organization_id = options[:organization_id]

    if organization_id.blank?
      if options[:category].present?
        # keep trending around while that version of the iPhone app is actively used.
        if %w[most_popular trending].include?(options[:category])
          results  = results.popular
          # Want to limit at 12 popular results
          # don't override what we set in the named scope by setting it here too
          per_page = 24
        elsif options[:category] == 'suggested' and user = options[:user]
          results = results.tagged_with(user.event_categories, :on => 'categories', :any => true)
        elsif options[:category] == 'featured'
          today = Date.today 
          results = results.featured_on(today)
        else
          categories = options[:category].to_a
          categories = categories.map{|c| c.humanize }
          results = results.tagged_with(categories, :on => 'categories', :any => true)
        end
      end
    else
      results = results.where(:organization_id => organization_id)
    end

    if options[:keywords].present? 
      keywords = Array(options[:keywords]).flatten.compact
      results  = results.order('events.starts_at ASC').search(keywords.join(' '))
    end 

    if options[:view_type] == 'map' && options[:after].present? && options[:category].present?
      results = Event.approved.after(start_time).before(start_time + 1.day).tagged_with(categories, :on => 'categories', :any => true)
    end

    if options[:view_type] == 'map' && options[:after].present?
      results = Event.approved.after(start_time).before(start_time + 1.day)
    end
    
    # results = results.joins(:categories, :image, :organization, :location) # uncommented to fix sorting bug

    # turns out to be much faster when we don't eager load organization categories
    # results = results.includes(:categories, :location, :image, :organization => [:categories, :locations])
    results = results.includes(:categories, :location, :image, :organization => [:locations])

    # WP: using this origin definition to scope location for search. This doesn't have any effect on the :origin set in the routes.
    # This definition scopes the search within 50 miles of the definition. Note: see within definition below.
    #
    
    if options[:order] == 'distance' && origin.present?
      results = results.near.order('events.starts_at ASC').order('events.name ASC')
    elsif options[:order] == 'name'
      results = results.order('events.name ASC')
    elsif options[:order] == 'starts_at'
      results = results.order('events.starts_at ASC')
    elsif options[:category] == 'featured'
      # don't resort
    else
      results = results.order('events.starts_at ASC')
    end

    if options[:event_city].present?
      origin  = options[:event_city]
      origin  = origin.humanize if origin

      # We're ready for scoping by location, but don't want to enable it yet
      # because we want iPhone users and people in other locations to see data
      #
      # Radius function is not working properly. Had to set radius to 1000 to pull relevant results. Unsure how :units is set in acts-as-geocadable gem
      # model or controller.

      within  = options[:within] = 1000
      results = results.origin(origin, :within => within) if origin.present?

      # results = results.origin(origin) if origin.present?
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

  # remember that users_count is a counter_cache column and will
  # not invoke before_save callbacks when it gets updated
  before_save :set_trend_weight
  def set_trend_weight
    self.trend_weight = users_count.to_i + anonymous_trend_count.to_i
  end

  # in seconds
  def duration
    (ends_at.to_i - starts_at.to_i).abs
  end

  # The annoying part about this is we need to make sure starts_at
  # exists and is updated before calling self.duration=
  # we'll just have to do that manually where needed and not through mass assignment
  def duration=(seconds)
    self.ends_at = seconds.to_i.seconds.from_now(self.starts_at)
  rescue
    raise 'starts_at must be set before assigning duration.'
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

  def prototype?
    repeating? and not clone?
  end

  def clone?
    prototype_id.present?
  end

  def update_repeating_events(event_hash)
    event_hash.each_pair do |key, values|
      key       = key.to_i
      date     = Chronic.parse(values[:date])
      duration = values[:duration]

      begin
        if self.id == key
          event = self
        else
          event = self.clones.find(key)
          if values[:remove]
            event.destroy
            next
          end
        end

        event.starts_at = date
        event.duration  = duration
        event.save if event.changed?
      rescue ActiveRecord::RecordNotFound
        next if values[:remove]
        self.clone(date, duration)
      end
    end
  end

  def clone(start_time, duration)
    cleaned_attributes = attributes.reject{|key, value| %w[id clone_count trend_weight users_count anonymous_trend_count starts_at ends_at].include?(key) }
    clone  = Event.new(cleaned_attributes)
    clone.category_list = category_list.reject{|c| c == 'Featured'}
    clone.starts_at = start_time
    clone.duration  = duration
    clone.prototype = self
    clone.save
  end

  # def feature!
  #   self.category_list.add('Featured')
  #   self.save
  # end

  # def unfeature!
  #   self.category_list.remove('Featured')
  #   self.save
  # end

  def featured?
    # TODO - Implement this properly
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
 
  def self.export_to_csv(options = {})
    FasterCSV.generate(options) do |csv|
      csv << [ "Organization Name", "Event Name", "Event Start Time", "Event End Time", "Feature ID", "Feature Date", "Feature Slot", "Feature Created Date", "Feature Updated Date" ]
      all.each do |event|
        csv << [ event.location.name, event.name, event.starts_at, event.ends_at, event.event_features.to_a.map{|e| e.event_id}.compact.join(", "), event.event_features.to_a.map{|e| e.date}.compact.join(", "), event.event_features.to_a.map{|e| e.slot}.compact.join(", "), event.event_features.to_a.map{|e| e.created_at}.compact.join(", "), event.event_features.to_a.map{|e| e.updated_at}.compact.join(", ") ]
      end
    end
  end
end


# == Schema Information
#
# Table name: events
#
#  id                    :integer         not null, primary key
#  uuid                  :string(255)
#  name                  :string(255)
#  description           :string(255)
#  starts_at             :datetime
#  ends_at               :datetime
#  repeating             :boolean
#  prototype_id          :integer
#  organization_id       :integer
#  image_id              :integer
#  location_id           :integer
#  created_at            :datetime
#  updated_at            :datetime
#  clone_count           :integer         default(0)
#  users_count           :integer         default(0)
#  trend_weight          :decimal(, )     default(0.0)
#  anonymous_trend_count :integer         default(0)
#  created_by_id         :integer
#  approved              :boolean         default(FALSE)
#

