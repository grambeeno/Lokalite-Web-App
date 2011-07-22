require 'test_helper'

class VenueTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: venues
#
#  id          :integer         not null, primary key
#  uuid        :string(255)
#  name        :string(255)
#  description :text
#  address     :string(255)
#  email       :string(255)
#  url         :string(255)
#  phone       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

