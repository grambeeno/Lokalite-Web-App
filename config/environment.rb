# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Lokalite::Application.initialize!

Geocode.geocoder = Graticule.service(:google).new('ABQIAAAAy20eG1RZkih79hiJ3rMHiRSULVwnM-lDnnuK0XBsp3zStsgwIBTeJ-UvgBzSoJdYL6rQjmLu_lcHjA')

