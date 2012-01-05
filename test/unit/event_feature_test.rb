require 'test_helper'

class EventFeatureTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
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

