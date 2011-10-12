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
#  name        :string(255)
#  description :text
#  date        :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

