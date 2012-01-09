class My::EventsController < My::Controller
  before_filter :set_organization
  before_filter :find_event_and_authorize

  def index
    # @events = Event.all
  end

  def show
  end

  def new
    if @organization.blank? && current_user.organizations.size == 1
      redirect_to new_my_event_path(:organization_id => current_user.organizations.first.id) and return
    end

    unless @organization.blank?
      today = Time.zone.now.to_date
      @event = @organization.events.new(:starts_at => today + 18.hours, :ends_at => today + 22.hours)
    end
  end

  def edit
  end


  def create
    attributes = clean_attributes(@event)
    duration = attributes.delete(:duration)
    @event = Event.new(attributes)
    @event.duration = duration

    if @event.save
      if @event.repeating and params.key?(:event_repeats)
        @event.update_repeating_events(params['event_repeats'].first)
      end

      Mailer.new_event_notification(@event).deliver
      flash[:notice] = 'Event was successfully created.'
      redirect_to event_path(@event.slug, @event.id)
    else
      render :action => 'new'
    end
  end

  def update
    attributes        = clean_attributes(@event)
    duration          = attributes.delete(:duration)
    @event.attributes = attributes
    @event.duration   = duration

    if @event.save
      if @event.repeating and params.key?(:event_repeats)
        @event.update_repeating_events(params['event_repeats'].first)
      end

      flash[:notice] = 'Event was successfully updated.'
      redirect_to event_path(@event.slug, @event.id)
    else
      render :action => 'edit'
    end
  end

  def update_multiple
		previous_event = nil
    for event_id in params[:events]
      if @event.id == event_id
        event = @event
      else
        event = @event.organization.events.find(event_id)
      end
      attributes = clean_attributes(event)

      # in the case that the user is creating a new image or location
      # we need to make sure that we don't create a copy for each event
      # store the previous_event and use its location and image instead
      if previous_event.is_a?(Event)
        attributes.delete(:location_attributes)
        attributes.delete(:image_attributes)
				event.location = previous_event.location
				event.image    = previous_event.image
      end

      event.duration   = attributes.delete(:duration)
      event.attributes = attributes

      if event.save
				previous_event = event
			else
        @event = event # so error form gets displayed
        render :action => 'edit' and return
      end
    end
    flash[:success] = "Successfully updated #{params[:events].size} copies of this event."
    redirect_to my_organization_path(@event.organization)
  end

  def destroy
    @event.destroy

    redirect_to my_organization_path(@event.organization)
  end

  def repeat
    if request.post?
      @event.update_repeating_events(params['event_repeats'].first)

      flash[:success] = "Successfully edited this event."
      redirect_to my_organization_path(@event.organization)
		else
			@clones = @event.clones.upcoming.unshift(@event)
    end
  end

  def feature
    if %w[event_id slot date].all?{|name| params.key?(name)}
      @event.event_features.create(
        :event_id => params[:event_id],
        :slot => params[:slot],
        :date => Chronic.parse(params[:date]).to_date
      )
      flash[:success] = "#{@event.name} will be featured in slot #{params[:slot].to_i + 1} on #{params[:date]}."
      redirect_to manage_featured_events_path
    else
      if real_user_is_admin?
        @organizations = Organization.order('name')
      else
        permission_denied
        # when we allow normal users to feature their own events
        # We'll have this instead:
        # @organizations = current_user.organizations
      end

      @events = @organizations.first.events.upcoming
    end
  end

  def events_for_organization
    organization = Organization.find(params[:organization_id])
    events = organization.events.upcoming
    render :partial => '/my/events/event_picker_content', :locals => {:events => events}
  end

  def featured_slots
    render :partial => '/my/events/featured_slots'
  end

  def unfeature
    if real_user_is_admin?
      date = Chronic.parse(params[:date]).to_date
      feature = EventFeature.where(:slot => params[:slot], :date => date).limit(1).first
      feature.destroy
      # flash[:notice] = feature.inspect
      flash[:notice] = "The event is no longer featured. Slot #{params[:slot].to_i + 1} is now available on #{params[:date]}."
      redirect_to manage_featured_events_path
    else
      permission_denied
    end
  end

  private

  def find_event_and_authorize
    id = params[:id] || params[:event_id]
    @event = Event.find(id) if id
    if @event
      permission_denied unless real_user_is_admin? || current_user.organizations.include?(@event.organization)
    end
  end

  def clean_attributes(event)
    attributes = params[:event].dup
    # remove attributes hash unless we want to actually create a new image or location
    attributes.delete(:image_attributes)    unless attributes[:image_id]    == 'new'
    attributes.delete(:location_attributes) unless attributes[:location_id] == 'new'

    categories = [attributes.delete(:first_category), attributes.delete(:second_category)]
    attributes[:category_list] = categories.join(', ')
    attributes
  end

  def set_organization
    id = params[:organization_id]
    id = params[:event][:organization_id] if params[:event] && id.blank?
    @organization = Organization.find(id) if id.present?
  end

end
