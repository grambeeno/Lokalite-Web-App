module EventsHelper

  def event_trended?(event)
    if logged_in?
      current_user.events.include?(event)
    else
      session[:trended_events] && session[:trended_events].include?(event.id)
    end
  end

  def trend_class(event)
    event_trended?(event) ? :trended : :trend
  end

  def event_location_string(event)
    organization = link_to(event.organization.name, organization_path(@event.organization.slug, @event.organization.id))

    if event.organization.name == event.location.name
      string = "@ #{organization}"
    else
      string = "By #{organization} @ #{event.location.name}"
    end
    raw string
  end

  # object can be an event or organization
  def report_grid_tracker(object, options = {})
    if object.is_a? Organization
      organization = object
    else
      organization = object.organization
    end

    # construct the object to send to ReportGrid
    #
    # remember that we are referring to a ReportGrid event
    # not a Lokalite event
    event = {
      :impression => {
        :id   => object.id,
        :type => "#{object.class.name} #{options[:type]}"
      }
    }

    # we'll extract and delete the path in JS
    event[:path] = "/organizations/#{organization.id}"

    raw " data-reportgrid='#{event.to_json}'"
  end
end
