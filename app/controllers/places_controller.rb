class PlacesController < ApplicationController
  before_filter :remember_location

  def index
    params[:per_page] = 12
    @organizations = Organization.browse(params)
  end

  def random_organization
    # size = Organization.all.size
    organization = Organization.order('random()').first
    redirect_to organization_path(organization.slug, organization.id)
    # render :action => 'organization', :id => organization.id
  end

  def organization
    @organization = Organization.find(params[:id])

    #joins = [:venues, {:venue => :location}]
    #includes = [:venues, {:venue => :location}]
    joins = []
    includes = []
    order = 'events.name'

    query = @organization.events
    query = query.joins(joins)
    query = query.includes(includes)
    query = query.order(order)

    page = params[:page]
    per_page = params[:per_page] || (Rails.env.development? ? 3 : 20)

    @events = query.paginate(:page => page, :per_page => per_page)
  end

protected

  def remember_location
    session[:location] = params[:location]
  end

end
