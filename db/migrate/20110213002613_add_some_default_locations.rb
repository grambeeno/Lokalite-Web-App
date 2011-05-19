class AddSomeDefaultLocations < ActiveRecord::Migration
  def self.up
    [
      "2030 17th strett, boulder, co, 80302",
      "paris, france",
      "new york, new york",
      "san francisco, ca",
      "tokyo, jp",
      "California",
      "Canada",
      "Colorado",
      "Connecticut",
      "Washington DC",
      "Florida",
      "Georgia",
      "Illinois",
      "Massachusetts",
      "Montana",
      "New York",
      "Oregon",
      "South Carolina",
      "Tennessee",
      "Texas",
      "Vermont",
      "Washington",
      "Wisconsin"
    ].each do |location|
      Location.for(location).save!
      sleep 1
    end
  end

  def self.down
  end
end


__END__











