module EventsHelper

  def address_for(event)
    location = event.venue.location
    parts = location.formatted_address.split(', ')

    result = ''
    for line in parts.reject{|p| p == 'USA'}
      separator = line.start_with?(location.locality) ? ', ' : '<br />'
      result << line + separator
    end
    raw result.chomp('<br />')
  end

  def google_maps_image(event, options = {})
    location = event.venue.location
    url = 'http://maps.googleapis.com/maps/api/staticmap?'

    options.reverse_merge!({
      :markers => "#{location.lat},#{location.lng}",
      :zoom   => 13,
      :size   => '240x100',
      :sensor => false
    })

    url << options.map{|key, value| key.to_s + '=' + value.to_s }.join('&')
    image_tag url, :alt => event.venue.name
  end

end
