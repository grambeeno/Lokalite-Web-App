module MapHelper

  # http://code.google.com/apis/maps/documentation/staticmaps/
  def google_maps_image(target, options = {})
    url = 'http://maps.googleapis.com/maps/api/staticmap?'

    if target.is_a?(Location)
      title = target.formatted_address
      options[:markers] = "#{target.latitude},#{target.longitude}"
      options[:zoom] = 13
    elsif target.is_a?(Plan)
      title = pluralize(target.events.size, 'Event')
      markers = []
      target.events.each_with_index do |event, index|
        markers << "label:#{index+1}|#{event.location.latitude},#{event.location.longitude}"
      end
      # with multiple markers and multiple options we pass more than one 'markers' param
      options[:markers] = markers.join('&markers=')
    else
      raise ArgumentError, "Expected Location or Plan, received #{target.class}"
    end

    options.reverse_merge!({
      :size   => '640x320',
      :sensor => false
    })

    url << options.map{|key, value| key.to_s + '=' + value.to_s }.join('&')
    image_tag url, :alt => '', :title => title, :class => 'tooltip'
  end

  def gmaps_url_for(location)
    raw(
      'http://maps.google.com/maps?f=q&amp;q=' +
      URI.escape(location.formatted_address.gsub(/\s+/, '+')) +
      '&amp;hl=en&amp;sll=' +
      location.coordinates +
      '&amp;ie=UTF8&amp;z=17&amp;iwloc=do_not_open'
    )
  end

  def markers_for_events(events)
    markers = []
    for event in events
      info_window = render(:partial => '/events/info_window', :locals => {:event => event})
      markers << "{name: '#{escape_javascript(event.name)}', lat: #{event.location.latitude.to_f}, lng: #{event.location.longitude.to_f}, infoWindow: '#{escape_javascript(info_window)}'}"
    end
    raw "[#{markers.join(',')}]"
  end


end
