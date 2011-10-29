module EventsHelper

  def tile_view_title
    if category = params[:category]
      if category == 'suggested'
        "Events from your favorite categories"
      else
        "#{title_for_category(category)} Events"
      end
    elsif keywords = params[:keywords]
      "Search results: #{keywords}"
    else
      "All Events"
    end
  end

  def event_path_options()

  end

  def event_trended?(event)
    if user_signed_in?
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

  def complex_dom_id(*args)
    args.map{|o| dom_id(o) }.join('-')
  end

  # embeds lokalite organization/event metadata for reportgrid tracking
  def reportgrid_event_tracker(event, base_type, options = {})
    organization = event.organization
   
    # construct the object to send to ReportGrid
    #
    # remember that we are referring to a ReportGrid event
    # not a Lokalite event
    
    reportgrid_event_data = {
      :org_category     => organization.category.name,
      :event_day        => event.starts_at.strftime('%a'),
      :signed_id        => user_signed_in?,
      :event_categories => {},
      :base_type        => base_type
    }
    
    event.categories.each { |category| 
      reportgrid_event_data[:event_categories][category] = true
    }

    reportgrid_event_data[:path] = "/#{organization.id}/#{event.location_id}/#{event.id}"

    raw " data-reportgrid='#{reportgrid_event_data.to_json}'"
  end
  
  # embeds lokalite organization metadata for reportgrid tracking
  def reportgrid_organization_tracker(organization, base_type, options = {})
   
    # remember that we are referring to a ReportGrid event
    # not a Lokalite event
    
    reportgrid_event_data = {
      :org_category => organization.category.name,
      :signed_id    => user_signed_in?,
      :base_type    => base_type
    }

    # we'll extract and delete the path in JS
    reportgrid_event_data[:path] = "/#{organization.id}"

    raw " data-reportgrid='#{reportgrid_event_data.to_json}'"
  end
end
