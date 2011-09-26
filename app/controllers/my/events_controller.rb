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
    attributes = clean_attributes(@event)
    duration = attributes.delete(:duration)
    @event = Event.new(attributes)
    @event.duration = duration

    if @event.save
      Mailer.new_event_notification(@event).deliver
      flash[:notice] = 'Event was successfully created.'
      if @event.repeating
        redirect_to my_event_repeat_path(@event)
      else
        redirect_to event_path(@event.slug, @event.id)
      end
    else
      render :action => 'new'
    end
  end

  def update_multiple
		previous_event = nil
    for event_id in params[:events]
      event = @event.organization.events.find(event_id)
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
        render :action => 'edit' and return
      end
    end
    flash[:success] = "Successfully updated #{params[:events].size} copies of this event."
    redirect_to my_organization_path(@event.organization)
  end

  def update
    attributes        = clean_attributes(@event)
    duration          = attributes.delete(:duration)
    @event.attributes = attributes
    @event.duration   = duration

    if @event.save
      flash[:notice] = 'Event was successfully updated.'
      if @event.repeating
        redirect_to my_event_repeat_path(@event)
      else
        redirect_to event_path(@event.slug, @event.id)
      end
    else
      render :action => 'edit'
    end
  end

  def destroy
    @event.destroy

    redirect_to my_organization_path(@event.organization)
  end

  def repeat
    if request.post?
      events = params['events'].first
      events.each_pair do |id, attributes|
        date     = Chronic.parse(attributes[:date])
        duration = attributes[:duration]
        id = id.to_i

        begin
          if @event.id == id
            event = @event
          else
            event = @event.clones.find(id)
            if attributes[:remove]
              event.destroy
              next
            end
          end

          event.starts_at = date
          event.duration  = duration
          event.save if event.changed?
        rescue ActiveRecord::RecordNotFound
          next if attributes[:remove]
          @event.clone(date, duration)
        end
      end

      flash[:success] = "Successfully edited this event."
      redirect_to my_organization_path(@event.organization)
		else
			@clones = @event.clones.upcoming.unshift(@event)
    end
  end

  def feature
    if real_user.admin?
      @event.feature!
      flash[:success] = "#{@event.name} has been featured!"
      redirect_to :back
    else
      permission_denied
    end
  end

  def unfeature
    if real_user.admin?
      @event.unfeature!
      flash[:notice] = "#{@event.name} is no longer a featured event."
      redirect_to :back
    else
      permission_denied
    end
  end

  private

  def find_event_and_authorize
    id = params[:id] || params[:event_id]
    @event = Event.find(id) if id
    if @event
      permission_denied unless current_user.organizations.include?(@event.organization)
    end
  end

  def clean_attributes(event)
    attributes = params[:event].dup
    # remove attributes hash unless we want to actually create a new image or location
    attributes.delete(:image_attributes)    unless attributes[:image_id]    == 'new'
    attributes.delete(:location_attributes) unless attributes[:location_id] == 'new'

    categories = [attributes.delete(:first_category), attributes.delete(:second_category)]
    categories << 'Featured' if event and event.featured?
    attributes[:category_list] = categories.join(', ')
    attributes
  end

  def set_organization
    id = params[:organization_id]
    id = params[:event][:organization_id] if params[:event] && id.blank?
    @organization = Organization.find(id) if id.present?
  end

end
