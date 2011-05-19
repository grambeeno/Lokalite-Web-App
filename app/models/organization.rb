class Organization < ActiveRecord::Base
# user/member relationships
#
  has_many(:user_organization_joins, :dependent => :destroy)
  has_many(:users, :through => :user_organization_joins) do
    def organization() proxy_owner end

    def add(user)
      user = User.for(user)
      push(user) unless include?(user)
      user
    end
  end

# event relationships
#
  has_many(:events, :dependent => :destroy)

# category relationships
#
  has_many(:category_context_joins, :as => :context, :dependent => :destroy)
  has_many(:categories, :through => :category_context_joins) do
    def organization() proxy_owner end

    def add(category)
      category = Category.for(category)
      push(category) unless include?(category)
      category
    end
  end
  has_one(:category_context_join, :as => :context, :dependent => :destroy) #, :conditions => {'category_context_joins.kind' => :primary})
  has_one(:category, :through => :category_context_join)

# image relationships
#
  has_many(:image_context_joins, :as => :context, :dependent => :destroy)
  has_many(:images, :through => :image_context_joins)

  has_one(:image_context_join, :as => :context, :dependent => :destroy, :conditions => {:kind => :primary})
  has_one(:image, :through => :image_context_join)

# location relationships
#
  has_many(:location_context_joins, :as => :context, :dependent => :destroy)
  has_many(:locations, :through => :location_context_joins)

  has_one(:location_context_join, :as => :context, :dependent => :destroy, :conditions => {:kind => :primary})
  has_one(:location, :through => :location_context_join)

# venue relationships
#
  has_many(:venue_context_joins, :as => :context, :dependent => :destroy)
  has_many(:venues, :through => :venue_context_joins)

  has_one(:venue_context_join, :as => :context, :dependent => :destroy, :conditions => {:kind => :primary})
  has_one(:venue, :through => :venue_context_join)


# status relationships
#
  has_many(:statuses, :as => :context, :dependent => :destroy, :order => 'created_at desc')

# lifecycle hooks
#
  before_validation(:on => :create) do |organization|
    organization.uuid ||= App.uuid

    if organization.address and not organization.location
      location = Location.for(organization.address)
      organization.location = location if location
    end
  end

  after_save(:on => :create) do |organization|
    organization.index! rescue nil
  end

# validations
#
  validates_presence_of :uuid
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :email
  validates_presence_of :url
  validates_presence_of :address

  #validates_presence_of :category
  #validates_associated :category

  #validates_presence_of :image
  #validates_associated :image

  #validates_presence_of :venues
  #validates_associated :venues

  #validates_presence_of :location
  #validates_associated :location

# full-text
#
  index do
    search
  end

  def Organization.browse(*args)
    options = Map.extract_options!(args)

    prefix = options[:location] || options[:prefix]
    prefix = prefix.prefix if prefix.respond_to?(:prefix)
    prefix = Location.absolute_path_for(prefix)

    category = options[:category]
    category = category.name rescue category
    category = Slug.for(category) if category

    keywords = args + Array(options[:keywords])
    keywords = Array(keywords).flatten.compact

    page = options[:page] || 1
    per_page = options[:per_page] || 20 
    page = [Integer(page), 1].max
    per_page = [Integer(per_page), 42].min

    per_page = 3 if Rails.env.development?

    order = options[:order]
    order =
      case order.to_s
        when 'name'
          'organizations.name'
        when 'date'
          'organizations.starts_at'
        when 'category'
          'categories.name'
        when 'venue'
          'venues.name'
        when 'location'
          'locations.prefix'
        else
          'organizations.updated_at DESC'
      end

    location = Location.find_by_prefix(prefix)
    unless location
      locations = Location.where('prefix like ?', "#{ prefix }%").order('prefix')
      location = locations.last
    end
    raise "no location for #{ prefix.inspect }" unless location

    #joins = [:categories, :venues, {:venues => :location}]
    #includes = [:categories, :venues, {:venues => :location}]
    joins = [:categories, :images, :venues, :statuses, {:venues => :location}]
    includes = [:categories, :images, :venues, :statuses]

    results = relation
    results = results.search(normalize_search_term("/location/#{ prefix }")) unless prefix.blank?
    results = results.search(normalize_search_term("/category/#{ category }")) unless category.blank?
    results = results.search(keywords.join(' ')) unless keywords.blank?
    #results = results.joins(joins)
    results = results.includes(includes)
    results = results.order(order)

    results.paginate(:page => page, :per_page => per_page)
  end

  def Organization.normalize_search_term(term)
    '/' + term.to_s.scan(/[a-zA-Z0-9]+/).join('/').downcase
  end

  def Organization.index!
    Organization.find_in_batches do |organizations|
      organizations.each do |organization|
        organization.index! rescue next
      end
    end
  end

  def index!
    organization = self

    location_searches = []
    category_searches = []

    organization.venues.each do |venue|
      location = venue.location
      prefixes = Location.prefixes_for(location.prefix)
      location_search = prefixes.map{|prefix| Organization.normalize_search_term("/location/#{ prefix }")}.join(' ')
      location_searches.push(location_search)
    end

    organization.categories.each do |category|
      category_search =  Organization.normalize_search_term("/category/#{ category.name }")
      category_searches.push(category_search)
    end

    terms = [
      location_searches,
      category_searches,
      organization.name, organization.description,
      organization.name, organization.description, organization.url, organization.email, organization.phone,
      venue.name, venue.description, venue.url, venue.email, venue.phone,
      location.country, location.administrative_area_level_1, location.administrative_area_level_2, location.locality
    ]

    search = terms.flatten.compact.join(' ')

    Organization.base.update(organization.id, :search => search)
  end

  def Organization.named?(name)
    return false if name.nil?
    where('name=?', name).first
  end

  def Organization.default_venue_for(organization)
    attributes = organization.attributes.slice(*Venue.column_names)
    venue = Venue.new(attributes)
    venue.location = organization.location
    venue
  end

  def slug
    parts = []
    parts.push(Slug.for(name))
    parts.join('/')
  end

  def build_default_venue!
    organization = self
    attributes = organization.attributes.slice(*Venue.column_names)
    venue = Venue.new(attributes)
    venue.location = organization.location
    venue.save!
    organization.venue = venue
  end

  def add_image!(arg)
    image = arg.is_a?(Image) ? arg : Image.for(arg)
    self.image = image
  end

  def set_status!(content)
    statuses.create!(:content => content)
  ensure
    touch
  end

  def status
    statuses.order('created_at desc').first
  end

# HACK
#
  def directory_path
    "/directory/location#{ location.prefix }/#{ Slug.for(name) }/#{ id }"
  end


=begin
  def to_dao(*args)
    if args.empty?
      map = Map.new
      map[:id] = id
      map[:name] = name
      map[:description] = description
      map[:url] = url
      map[:email] = email
      map[:phone] = phone
      map[:address] = address
      map[:category] = category

      if location
        map[:location] = Map[:prefix, location.prefix, :ll, location.ll, :address, location.address]
      end

      map[:categories] = categories.map{|category| category.name}

      if image
        map[:image] = App.url(image.url)
      end

      unless venues.blank?
        map[:venues] = venues.map{|venue| Map.for(venue.attributes)}
      end
      
      map
    else
      Organization.to_dao(record=self, *args)
    end
  end
=end

end
