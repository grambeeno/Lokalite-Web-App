# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Lokalite::Application.initialize!

Geocode.geocoder = Graticule.service(:google).new('')

