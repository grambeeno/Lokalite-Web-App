class EventsController < ApplicationController
  # before_filter :show_splash_to_new_visitors
  before_filter :remember_location

  def index
    if params.delete(:utf8)
      redirect_to events_path(params)
    end
    if params[:category] == 'suggested'
      flash[:error] = 'Update your profile with some favorite categories in order to use suggestions.'
      redirect_to edit_profile_path
    end
    if params[:view_type] == 'map'
      params[:per_page] = 24
    else
      params[:per_page] = 12
    end
    params[:user] = current_user if user_signed_in?
    @events = Event.browse(params)
  end

  def show
    includes = [:categories, :image, :organization]
    @event = Event.where(:id => params[:id]).includes(includes).first

    redirect_to('/404.html') and return unless @event
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

end
