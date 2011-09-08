# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Lokalite::Application.initialize!

Geocode.geocoder = Graticule.service(:multi).new(
  Graticule.service(:google).new('ABQIAAAAy20eG1RZkih79hiJ3rMHiRSULVwnM-lDnnuK0XBsp3zStsgwIBTeJ-UvgBzSoJdYL6rQjmLu_lcHjA'),
  Graticule.service(:geocoder_ca).new(),
  Graticule.service(:geocoder_us).new()
) do |result|
  [:address, :street].include?(result.precision)
end

