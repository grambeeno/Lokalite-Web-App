class Organization < ActiveRecord::Base
  include PgSearch
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

  has_many :locations, :dependent => :destroy, :include => :geocoding
  # still need to enable this for has_many associations
  # acts_as_geocodable :through => :locations
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
    # self.locations.build(:region => 'Colorado')
    # self.image = Image.new
  end

  pg_search_scope :search, :against => [[:name, 'A'], [:description, 'B']]

  def Organization.browse(*args)
    options = Map.extract_options!(args)

    location = options[:location] || 'Boulder, CO'

    keywords = args + Array(options[:keywords])
    keywords = Array(keywords).flatten.compact

    page = options[:page] || 1
    per_page = options[:per_page] || 20 
    page = [Integer(page), 1].max
    per_page = [Integer(per_page), 42].min

    case options[:order].to_s
      when 'name'
        order = 'organizations.name'
      when 'category'
        order = 'categories.name'
      else
        order = 'organizations.updated_at DESC'
    end

    results = relation
    results = results.tagged_with(options[:category], :on => 'categories') unless options[:category].blank?

    results = results.search(keywords.join(' ')) unless keywords.blank?

    # TODO - filter by location
    # results = results.origin([40.014781,-105.186989], :within => 3.5)

    # results = results.joins(:statuses, :locations)
    results = results.includes(:image, :statuses, :locations)
    results = results.order(order)

    results.paginate(:page => page, :per_page => per_page)
  end

  def Organization.normalize_search_term(term)
    '/' + term.to_s.scan(/[a-zA-Z0-9]+/).join('/').downcase
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

  def Organization.to_dao(*args)
    remove = %w[]
    add    = %w[status location categories]
    super(*args).reject{|arg| remove.include?(arg)} + add
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
#  description :string(255)
#  email       :string(255)
#  url         :string(255)
#  phone       :string(255)
#  image       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

