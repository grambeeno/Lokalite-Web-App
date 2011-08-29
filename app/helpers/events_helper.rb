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
end
