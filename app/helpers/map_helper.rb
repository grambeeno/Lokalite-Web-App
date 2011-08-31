module MapHelper

  def google_maps_image(location, options = {})
    url = 'http://maps.googleapis.com/maps/api/staticmap?'

    options.reverse_merge!({
      :markers => "#{location.latitude},#{location.longitude}",
      :zoom   => 13,
      :size   => '640x320',
      :sensor => false
    })

    url << options.map{|key, value| key.to_s + '=' + value.to_s }.join('&')
    image_tag url, :alt => '', :title => location.formatted_address, :class => 'tooltip'
  end

  def gmaps_url_for(location)
    raw(
      'http://maps.google.com/maps?f=q&amp;source=s_q&amp;q=' +
      URI.escape(location.formatted_address.gsub(/\s+/, '+')) +
      '&amp;hl=en&amp;sll=' +
      location.coordinates +
      '&amp;ie=UTF8&amp;z=12&amp;ll=' +
      location.coordinates +
      '&amp;iwloc=do_not_open'
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
