module DirectoryHelper

  def places_page?
    params[:controller] == 'places'
  end

  def index_view_title
    if category = params[:category]
      if params[:category] && keywords = params[:keywords]
        "Search results: #{keywords} in #{title_for_category(category)}"
      elsif category == 'suggested'
        "Suggested Places"
      else
        "#{title_for_category(category)}"
      end
    elsif keywords = params[:keywords]
      "Search results: #{keywords} in All Places"
    else
      "All Places"
    end
  end

  # used to persist existing data in URL, but gives an easy way to override
  # or remove certain params. Also allows keeping other arbitrary params.
  def places_path_with_options(custom_options = {})
    keys = [:origin, :view_type, :category, :event_city, :event_state]

    # allow user to pass other params they want to persist:
    # organizations_path_with_options(:keep => [:keywords])
    if custom_options.key?(:keep)
      keys << custom_options.delete(:keep)
      keys.flatten!
    end

    # seed options with data that we have from URL
    options = params.reject{|key, value| !keys.include?(key.to_sym) }

    # override options with options passed manually
    options.merge!(custom_options)

    # take care of some special cases
    if options[:category] == 'all_places' 
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

    places_path(options)
  end

end
