class EventFeature < ActiveRecord::Base
  belongs_to :event

  validates_presence_of :date, :event_id, :slot

  validates_uniqueness_of :slot,     :scope => :date
  validates_uniqueness_of :event_id, :scope => :date

  def self.export_featured_to_csv(options = {})
    FasterCSV.generate(options) do |csv|
      csv << [ "Organization Name", "Location Name", "Location Address", "Location City", "Location State", "Location Zip Code", "Event Name", "Event Description", "Event Start Time", "Event End Time" ]
      event.featured.each do |event|
        csv << [ event.organization.name, event.location.name, event.location.geocoded_street, event.location.locality, event.location.region, event.location.postal_code, event.name, event.description, event.starts_at, event.ends_at ]
      end
    end
  end
end

# == Schema Information
#
# Table name: event_features
#
#  id         :integer         not null, primary key
#  event_id   :integer
#  date       :date
#  slot       :integer
#  created_at :datetime
#  updated_at :datetime
#

