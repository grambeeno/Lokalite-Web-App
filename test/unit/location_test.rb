require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end




# == Schema Information
#
# Table name: locations
#
#  id              :integer         not null, primary key
#  uuid            :string(255)
#  name            :string(255)
#  street          :string(255)
#  locality        :string(255)
#  region          :string(255)
#  postal_code     :string(255)
#  country         :string(255)
#  organization_id :integer
#  utc_offset      :float
#  created_at      :datetime
#  updated_at      :datetime
#

