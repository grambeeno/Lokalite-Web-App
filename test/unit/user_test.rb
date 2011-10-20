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
#  id                     :integer         not null, primary key
#  uuid                   :string(255)     not null
#  email                  :string(255)
#  encrypted_password     :string(128)     default(""), not null
#  time_zone              :string(255)     default("Mountain Time (US & Canada)")
#  handle                 :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#

