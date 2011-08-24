class PlacesController < ApplicationController
  before_filter :set_context
  before_filter :remember_location

  def index
    @organizations = Organization.browse(@context)
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

    page = @context[:page]
    per_page = @context[:per_page] || (Rails.env.development? ? 3 : 20)

    @events = query.paginate(:page => page, :per_page => per_page)
  end

protected

  def set_context
    @context = Map[
      #:location     , session[:location],
      :location     , (params.has_key?(:location) ? Location.absolute_path_for(params[:location]) : nil),
      :organization , params[:organization],
      :category     , params[:category],
      #:date         , params[:date],
      :keywords     , params[:keywords],
      :order        , params[:order],
      :page         , params[:page],
      :per_page     , params[:per_page]
    ]
  ensure
    @context[:organization] = Organization.find(params[:id]) if params[:id]
  end

  def remember_location
    session[:location] = @context[:location]
  end

end
