require 'test_helper'

class PlanUserInvitationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: plan_user_invitations
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  plan_id    :integer
#  accepted   :boolean
#  created_at :datetime
#  updated_at :datetime
#

