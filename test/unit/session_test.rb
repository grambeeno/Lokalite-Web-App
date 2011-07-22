require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: sessions
#
#  id         :integer         not null, primary key
#  data       :text            default("--- {}\n\n")
#  user_id    :integer         not null
#  created_at :datetime
#  updated_at :datetime
#

