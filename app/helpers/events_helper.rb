module EventsHelper

  def google_maps_image(event, options = {})
    location = event.location
    url = 'http://maps.googleapis.com/maps/api/staticmap?'
  
    options.reverse_merge!({
      :markers => "#{location.latitude},#{location.longitude}",
      :zoom   => 13,
      :size   => '640x320',
      :sensor => false
    })
  
    url << options.map{|key, value| key.to_s + '=' + value.to_s }.join('&')
    image_tag url, :alt => location.name
  end

end
