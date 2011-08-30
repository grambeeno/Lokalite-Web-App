class EventsController < ApplicationController
  # before_filter :show_splash_to_new_visitors
  before_filter :remember_location

  def index
    if params[:view_type] == 'map'
      params[:per_page] = 24
    else
      params[:per_page] = 12
    end
    @events = Event.browse(params)
  end

  def show
    includes = [:categories, :image, :organization]
    @event = Event.where(:id => params[:id]).includes(includes).first

    redirect_to('/404.html') and return unless @event

    @recommended = ( Event.featured.random.limit(3) + Event.prototypes.random.limit(3) ).first(3)
  end

# TODO - render :nothing doesn't trigger success in jq... why?
#
  def feature
    if current_user and current_user.admin?
      Rails.logger.debug params.inspect
      id = params[:id]
      featured = params[:featured]
      Event.find(id).featured!(featured)
    end
    render(:text => '', :status => 200, :layout => false)
  end

private

  def remember_location
    session[:location] = params[:location]
  end

  def show_splash_to_new_visitors
    unless params[:location] or params[:organization]
      session[:splash] = true
    end
  end


=begin
  def ensure_params_update_location
    if params.has_key?(:location) and Location.absolute_path_for(params[:location]) != Location.absolute_path_for(session[:location])
      session[:location] = params[:location]
      url =
        browse_path(
          :location => session[:location],
          :keywords => params[:keywords],
          :order => params[:order],
          :page => params[:page]
        )
      redirect_to(url)
    end
  end

  def ensure_browsing_by_location_or_organization
    if params[:location].blank? and params[:organization].blank?
      url =
        browse_path(
          :location => Location.default.prefix,
          :keywords => params[:keywords],
          :order => params[:order],
          :page => params[:page]
        )
      redirect_to(url)
      return
    end
  end

=end

end
