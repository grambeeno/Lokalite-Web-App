class Venue < ActiveRecord::Base
  has_one(:location_context_join, :as => :context, :dependent => :destroy)
  has_one(:location, :through => :location_context_join)

  has_many(:venue_context_joins, :dependent => :destroy)

  validates_presence_of :uuid
  validates_presence_of :name
  validates_presence_of :address

  before_validation(:on => :create) do |venue|
    venue.uuid ||= App.uuid

    if venue.address and not venue.location
      location = Location.for(venue.address)
      venue.location = location if location
    end
  end

  def Venue.options_for_select(options = {})
    options.to_options!
    organization = options[:organization] || options[:organization_id]
    #organization = Organization.find(organization) if(organization and !organization.is_a?(Organization))
    organization = organization.id if organization.is_a?(Organization)

    venues =
      if organization
        VenueContextJoin.where(:context_type => Organization.name, :context_id => organization).joins(:venue).map(&:venue)
      else
        relation.select(:id, :name)
      end

    list = venues.map{|venue| [venue.id, venue.name]}
    list.unshift([nil, nil]) unless options[:blank]==false
    list
  end

  def time_for(t)
    location.time_for(t)
  end
end
