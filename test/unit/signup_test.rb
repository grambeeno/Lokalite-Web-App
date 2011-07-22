require 'test_helper'

class SignupTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: signups
#
#  id             :integer         not null, primary key
#  email          :string(255)
#  password       :string(255)
#  user_id        :integer
#  delivery_count :integer         default(0)
#  created_at     :datetime
#  updated_at     :datetime
#

