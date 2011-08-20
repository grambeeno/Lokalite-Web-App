class My::EventsController < My::Controller
  before_filter :set_organization
  before_filter :find_event_and_authorize

  def index
    @events = Event.all
  end

  def show
  end

  def new
    if @organization.blank? && current_user.organizations.size == 1
      redirect_to new_my_event_path(:organization_id => current_user.organizations.first.id) and return
    end

    unless @organization.blank?
      @event = @organization.events.new(:starts_at => Date.today + 18.hours, :ends_at => Date.today + 22.hours)
    end
  end

  def edit
  end

  def create
    clean_attributes
    @event = Event.new(params[:event])

    if @event.save
      flash[:notice] = 'Event was successfully created.'
      redirect_to event_path(@event.slug, @event.id)
    else
      render :action => "new"
    end
  end

  def update
    clean_attributes

    if @event.update_attributes(params[:event])
      flash[:notice] = 'Event was successfully updated.'
      redirect_to event_path(@event.slug, @event.id)
    else
      render :action => "edit"
    end
  end

  def destroy
    @event.destroy

    redirect_to(events_url)
  end

  private

  def find_event_and_authorize
    @event = Event.find(params[:id]) if params[:id]
    if @event
      permission_denied unless current_user.organizations.include?(@event.organization)
    end
  end

  def clean_attributes
    params[:event].delete(:image_attributes)    unless params[:event][:image_id]    == 'new'
    params[:event].delete(:location_attributes) unless params[:event][:location_id] == 'new'
  end

  def set_organization
    id = params[:organization_id]
    id = params[:event][:organization_id] if params[:event] && id.blank?
    @organization = Organization.find(id) if id.present?
  end

end
