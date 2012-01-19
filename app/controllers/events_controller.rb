class EventsController < ApplicationController
  before_filter :remember_location

  def index
    if params.delete(:utf8)
      redirect_to events_path(params)
    end
    if params[:view_type] == 'map'
      params[:per_page] = 24
    else
      params[:per_page] = 12
    end
    params[:user] = current_user if user_signed_in?


    if params[:category] == "suggested" && params[:user].event_categories.empty?
      flash[:error] = 'Update your profile with some favorite categories in order to use suggestions.'
      redirect_to edit_profile_path
    end

    @events = Event.browse(params)
    if params[:category] == 'featured'
      @events = ensure_enough_featured_events(@events)
    end
  end

  def show
    if params[:invitation] and !user_signed_in?
      session[:event_invitation_id] = params[:id]
    end

    includes = [:categories, :image, :organization]
    @event = Event.where(:id => params[:id]).includes(includes).first

    redirect_to('/404.html') and return unless @event
  end

private

  def ensure_enough_featured_events(events)
    events = events.to_a
    events.delete_at(2)
    if events.size < 12
      slots = events.map{ |e| e.event_features.first.slot }
      12.times do |slot|
        unless slots.include?(slot)
          # insert the next featured event in the correct slot
          event = Event.next_featured_in_slot(slot)
          events.insert(slot, event) if event
        end
      end
    end
    events
  end

  def remember_location
    session[:location] = params[:location]
  end

end
