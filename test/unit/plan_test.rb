require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end



# == Schema Information
#
# Table name: plans
#
#  id          :integer         not null, primary key
#  user_id     :integer
#  uuid        :string(255)
#  title       :string(255)
#  public      :boolean         default(FALSE)
#  description :text
#  event_list  :text
#  starts_at   :datetime
#  ends_at     :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

