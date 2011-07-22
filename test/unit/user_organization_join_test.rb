require 'test_helper'

class UserOrganizationJoinTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: user_organization_joins
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  organization_id :integer
#  kind            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

