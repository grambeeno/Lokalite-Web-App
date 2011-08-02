# Directory is now publicly known as "Places"
# May want to rename if this change sticks
class DirectoryController < ApplicationController
  before_filter :ensure_location_or_organization, :only => :browse
  before_filter :redirect_when_location_is_being_set
  before_filter :set_context
  before_filter :remember_location
  before_filter :ensure_searches_redirect_to_browse, :except => :browse

  def index
    redirect_to(browse_path)
  end

  def browse
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
  def ensure_location_or_organization
    if params[:id] and params[:organization].blank?
      url =
        browse_path(
          :organization => params[:id],
          :keywords => params[:keywords],
          :order => params[:order],
          :page => params[:page]
        )
      redirect_to(url)
      return
    end

    unless params[:location] or params[:organization]
      url =
        browse_path(
          :location => default_location,
          :keywords => params[:keywords],
          :order => params[:order],
          :page => params[:page]
        )
      redirect_to(url)
      return
    end
  end

  def redirect_when_location_is_being_set
    if flash[:location]
      url =
        browse_path(
          :location => flash[:location],
          :keywords => params[:keywords],
          :order => params[:order],
          :page => params[:page]
        )
      redirect_to(url)
      flash.discard(:location)
    end
  end

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

  def ensure_searches_redirect_to_browse
    unless params[:keywords].blank?
      redirect_to(browse_path(:keywords => params[:keywords]))
      return
    end
  end

  def browse_path(options = {})
    browse_directory_path(options)
  end
  helper_method(:browse_path)

### ["previous_page", "current_page", "next_page", "per_page", "total_pages"]
#
  def paginate(collection)
    page = OpenStruct.new
    page.tot = collection.total_pages
    page.pre = collection.previous_page
    page.cur = collection.current_page
    page.nxt = collection.next_page
    #return '' if collection.previous_page

    context = (defined?(@context) ? @context : {}).to_options!

    order = context[:order]
    keywords = context[:keywords]
    organization = context[:organization]

    options = {}
    options[:order] = order unless order.blank?
    options[:keywords] = keywords unless keywords.blank?
    options[:organization] = organization unless organization.blank?
    #options[:location] = false if options[:organization]

    links = OpenStruct.new
    links.pre = browse_path(options.merge(:page => page.pre))
    links.cur = browse_path(options.merge(:page => page.cur))
    links.nxt = browse_path(options.merge(:page => page.nxt))

    fmt = lambda{|n| ('%4d' % n).gsub(/\s/, '&nbsp')}
    lfmt = lambda{|s| a = s.to_s.split(//); a.unshift('&nbsp;') until a.size >= 4; a.join}
    rfmt = lambda{|s| a = s.to_s.split(//); a.push('&nbsp;') until a.size >= 4; a.join}

    div_(:class => 'pagination'){
      a_(:href => links.pre, :title => "previous page", :style => (page.pre ? '' : 'opacity:0.0')){ tagz.raw('&larr;') }

      if page.nxt
        a_(:href => links.nxt, :title => "next", :disabled => true){  "#{ lfmt[page.cur] }/#{ rfmt[page.tot] }" }
      else
        a_(:href => links.pre, :title => "prev", :disabled => true){  "#{ lfmt[page.cur] }/#{ rfmt[page.tot] }" }
      end

      a_(:href => links.nxt, :title => "next page", :style => (page.nxt ? '' : 'opacity:0.0')){  tagz.raw('&rarr;') }
    }
  end
  helper_method(:paginate)

end
