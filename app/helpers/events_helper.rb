module EventsHelper
  def event_index_page?
    params[:controller] == 'events' && params[:action] == 'index'
  end

  def tile_view_title
    if category = params[:category]
      if params[:category] && keywords = params[:keywords]
        "Search results: #{keywords} in #{title_for_category(category)}"
      elsif category == 'suggested'
        "Suggested Events"
      else
        "#{title_for_category(category)}"
      end
    elsif keywords = params[:keywords]
      "Search results: #{keywords} in All Events" 
    else
      "All Events"
    end
  end

  # used to persist existing data in URL, but gives an easy way to override
  # or remove certain params. Also allows keeping other arbitrary params.
  def events_path_with_options(custom_options = {})
    keys = [:origin, :view_type, :category, :after, :event_city, :event_state, :event_start_time] 

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
    if options[:category] == 'all_events' 
      options.delete(:category)
      options.delete(:after)
      options.delete(:event_city)
      options.delete(:event_state)
      options.delete(:event_start_time)
    end

    # WP: it isn't pretty but it will keep a redirect loop from occuring when
    # you search and then click the featured category on the left sidebar.
    # The real issue is with the :after key but I removed the other keys to 
    # beautify the URL :P
    if options[:category].present?
      options.delete(:after)
      options.delete(:event_city)
      options.delete(:event_state)
      options.delete(:event_start_time)
    end

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
