class Organization < ActiveRecord::Base
  include PgSearch

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

  acts_as_taggable_on :categories
  def category
    categories.first
  end

  validate :category_is_present
  def category_is_present
    errors.add_to_base "Category can't be blank" unless category_list.present?
  end

  validates_presence_of :uuid
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :email

  validates_format_of :url, :with => URI::regexp(%w(http https)), :allow_blank => true
  before_validation :preprocess_url
  def preprocess_url
    self.url = "http://#{url}" unless url.blank? or url.start_with?('http')
  end

  # We would use:
  # validates_length_of :description, :maximum => 500
  # but it counts line breaks as 2 chars. Need to do it ourselves.
  validate :check_description_length
  def check_description_length
    return if description.blank?
    stripped = description.gsub /\r\n/, ' '
    if stripped.length > 500
      errors.add(:description, 'is too long (maximum is 500 characters)')
    end
  end

  before_validation(:on => :create) do |organization|
    organization.uuid ||= App.uuid
  end

  has_many :event_images, :dependent => :destroy
  mount_uploader :image, ImageUploader

  validates_presence_of :image

  has_many :locations, :dependent => :destroy, :include => :geocoding
  # still need to enable this for has_many associations
  # acts_as_geocodable :through => :locations
  accepts_nested_attributes_for :locations
  # validates_presence_of :locations
  validates_associated  :locations

  def location
    locations.first
  end

  def address
    location && location.formatted_address
  end

  pg_search_scope :search, :against => [[:name, 'A'], [:description, 'B']]

  def self.browse(*args)
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
    results = results.tagged_with(options[:category].humanize, :on => 'categories') unless options[:category].blank?

    results = results.search(keywords.join(' ')) unless keywords.blank?

    # TODO - filter by location
    # results = results.origin([40.014781,-105.186989], :within => 3.5)

    # results = results.joins(:locations)
    results = results.includes(:locations, :categories)
    results = results.order(order)

    results.paginate(:page => page, :per_page => per_page)
  end

  def self.normalize_search_term(term)
    '/' + term.to_s.scan(/[a-zA-Z0-9]+/).join('/').downcase
  end

  def self.named?(name)
    return false if name.nil?
    where('name=?', name).first
  end

  def slug
    parts = []
    parts.push(Slug.for(name))
    parts.join('/')
  end

  def directory_path
    "/directory/location#{ location.prefix }/#{ Slug.for(name) }/#{ id }"
  end

  # the following are needed for to_dao
  def image_full
    image_url
  end
  def image_large
    image_url(:large)
  end
  def image_medium
    image_url(:medium)
  end
  def image_small
    image_url(:small)
  end
  def image_thumb
    image_url(:thumb)
  end


  def self.to_dao(*args)
    remove = %w[image]
    add    = %w[location categories image_thumb image_small image_medium image_large image_full]
    super(*args).reject{|arg| remove.include?(arg)} + add
  end

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
#  image       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

