require 'test_helper'

class EventTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end








# == Schema Information
#
# Table name: events
#
#  id                    :integer         not null, primary key
#  uuid                  :string(255)
#  name                  :string(255)
#  description           :string(255)
#  starts_at             :datetime
#  ends_at               :datetime
#  repeating             :boolean
#  prototype_id          :integer
#  organization_id       :integer
#  image_id              :integer
#  location_id           :integer
#  created_at            :datetime
#  updated_at            :datetime
#  clone_count           :integer         default(0)
#  users_count           :integer         default(0)
#  trend_weight          :decimal(, )     default(0.0)
#  anonymous_trend_count :integer         default(0)
#  created_by_id         :integer
#  approved              :boolean         default(FALSE)
#

