class EventsController < ApplicationController
  before_filter :remember_location

  def index
    # utf8 is added when searching
    #if params.delete(:utf8)
    #  redirect_to events_path(params)
    #end
    # Don't apply date filters to featured event page
    if params.key?(:after) and params[:category] == 'featured' 
      params.delete(:category)
      redirect_to events_path(params)
    end
    if request.format == 'xls' or request.format == 'txt' or request.format == 'csv'  
      # WP:  Date range for Boulder Weekly to download these files on Tuesday and pull results for Thursday to next Wednesday
      # I couldn't put results in the Event Model b/c it was effecting web and iPhone app results
      # Event.approved.after(Date.today + 3.days).before(Date.today + 9.days).order('events.starts_at ASC')
      @events =  ensure_enough_featured_events(@events)
    elsif params[:category] == 'featured'
      @events = ensure_enough_featured_events(@events).shuffle 
    elsif params[:category] == 'suggested'
      @events = @events.shuffle
    else
      @events = Event.browse(params) 
    end 
    params[:user] = current_user if user_signed_in?
   
    # Don't apply date filters to suggested event page
    # if params.key?(:after) and params[:category] == 'suggested'
      # params.delete(:category)
      # redirect_to events_path(params)
    # end 

    if params[:category] == "suggested" && params[:user].event_categories.empty?
      flash[:error] = 'Update your profile with some favorite categories in order to use suggestions.'
      redirect_to edit_profile_path
    end   

    respond_to do |format|
      format.html
      format.csv { send_data @events.export_to_csv() }
      format.xls # { send_data @events.to_csv(:col_sep => "\t") }
      format.txt { send_data @events.export_to_csv }
      # format.rtf WP: there isn't good support for rtf on ruby yet. Ruby-RTF gem is available but unstable.
    end 
  end

  def shuffle
    sort_by {rand}
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
    if events.size < 24 
      slots = events.map{ |e| e.event_features.first.slot }
      24.times do |slot|
        unless slots.include?(slot)
          # insert the next featured event in the correct slot
          # insert nil values anyway to get correct placement, then compact array later
          event = Event.next_featured_in_slot(slot)
          events.insert(slot, event)
        end
      end
    end
    events.compact
  end

  def remember_location
    session[:location] = params[:location]
  end 
end
