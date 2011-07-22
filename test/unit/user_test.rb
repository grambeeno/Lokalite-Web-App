require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  uuid       :string(255)     not null
#  email      :string(255)
#  password   :string(255)
#  time_zone  :string(255)     default("Mountain Time (US & Canada)")
#  handle     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

