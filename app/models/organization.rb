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

  has_many :events, :dependent => :destroy
  has_many :locations, :dependent => :destroy
  has_many(:statuses, :as => :context, :dependent => :destroy, :order => 'created_at desc')

  acts_as_taggable_on :categories

  validates_presence_of :uuid
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :email

  validates_length_of :description, :maximum => 140

  before_validation(:on => :create) do |organization|
    organization.uuid ||= App.uuid
  end


  # has_many(:image_context_joins, :as => :context, :dependent => :destroy)
  # has_many(:images, :through => :image_context_joins)

  has_one(:image_context_join, :as => :context, :dependent => :destroy, :conditions => {:kind => :primary})
  has_one(:image, :through => :image_context_join)

  # accepts_nested_attributes_for :image
  validates_presence_of :image
  # validates_associated :image

  def image_file=(arg)
    image = arg.is_a?(Image) ? arg : Image.for(arg)
    image.save
    self.image = image
  end

  accepts_nested_attributes_for :locations
  validates_presence_of :locations
  validates_associated  :locations

  def location
    locations.order('created_at').first
  end

  def address
    location.formatted_address
  end

  after_initialize :build_default_location

  def build_default_location
    self.locations.build(:address_state => 'Colorado')
    # self.image = Image.new
  end


  # after_save(:on => :create) do |organization|
  #   organization.index! rescue nil
  # end

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

    # joins = [:categories, :images, :statuses, {:venues => :location}]
    # includes = [:categories, :images, :statuses]
    joins = [:images, :statuses, :location]
    includes = [:images, :statuses, :location]

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

    organization.categories.each do |category|
      category_search =  Organization.normalize_search_term("/category/#{ category.name }")
      category_searches.push(category_search)
    end

    terms = [
      location_searches,
      category_searches,
      organization.name, organization.description,
      organization.name, organization.description, organization.url, organization.email, organization.phone,
      location.country, location.administrative_area_level_1, location.administrative_area_level_2, location.locality
    ]

    search = terms.flatten.compact.join(' ')

    Organization.base.update(organization.id, :search => search)
  end

  def Organization.named?(name)
    return false if name.nil?
    where('name=?', name).first
  end

  def slug
    parts = []
    parts.push(Slug.for(name))
    parts.join('/')
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

  def self.to_dao(*args)
    super(*args).reject{|arg| arg == 'search'} << :status
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


# == Schema Information
#
# Table name: organizations
#
#  id          :integer         not null, primary key
#  uuid        :string(255)
#  name        :string(255)
#  description :text
#  email       :string(255)
#  url         :string(255)
#  phone       :string(255)
#  category    :string(255)
#  image       :string(255)
#  search      :text
#  created_at  :datetime
#  updated_at  :datetime
#

