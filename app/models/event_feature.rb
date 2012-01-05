class EventFeature < ActiveRecord::Base
  belongs_to :event

  validates_presence_of :date, :event_id, :slot

  validates_uniqueness_of :slot,     :scope => :date
  validates_uniqueness_of :event_id, :scope => :date

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

