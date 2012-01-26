module EventsHelper
  def event_index_page?
    params[:controller] == 'events' && params[:action] == 'index'
  end

  def tile_view_title
    if category = params[:category]
      if category == 'suggested'
        "Suggested Events"
      else
        "#{title_for_category(category)}"
      end
    elsif keywords = params[:keywords]
      "Search results: #{keywords}"
    else
      "All Events"
    end
  end

  # used to persist existing data in URL, but gives an easy way to override
  # or remove certain params. Also allows keeping other arbitrary params.
  def events_path_with_options(custom_options = {})
    keys = [:origin, :view_type, :category, :after]

    # allow user to pass other params they want to persist:
    # events_path_with_options(:keep => [:keywords])
    if custom_options.key?(:keep)
      keys << custom_options.delete(:keep)
      keys.flatten!
    end

    # seed options with data that we have from URL
    options = params.reject{|key, value| !keys.include?(key.to_sym) }

    # override options with options passed manually
    options.merge!(custom_options)

    # take care of some special cases
    options.delete(:category) if options[:category] == 'all_events'

    events_path(options)
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
