require 'test_helper'

class TokenTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: tokens
#
#  id           :integer         not null, primary key
#  uuid         :string(255)
#  kind         :string(255)
#  context_id   :integer
#  context_type :string(255)
#  counter      :integer         default(0)
#  expires_at   :datetime
#  data         :text            default("--- {}\n\n")
#  created_at   :datetime
#  updated_at   :datetime
#

