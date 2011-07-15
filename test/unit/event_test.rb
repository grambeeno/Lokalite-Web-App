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
#  id              :integer         not null, primary key
#  uuid            :string(255)
#  organization_id :integer
#  name            :string(255)
#  description     :text
#  starts_at       :datetime
#  ends_at         :datetime
#  all_day         :boolean
#  repeating       :boolean
#  prototype_id    :integer
#  search          :text
#  created_at      :datetime
#  updated_at      :datetime
#  clone_count     :integer         default(0)
#  repeats         :string(255)
#

