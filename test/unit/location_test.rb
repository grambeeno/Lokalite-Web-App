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
#  id                          :integer         not null, primary key
#  uuid                        :string(255)
#  address                     :string(255)
#  formatted_address           :string(255)
#  country                     :string(255)
#  administrative_area_level_1 :string(255)
#  administrative_area_level_2 :string(255)
#  locality                    :string(255)
#  prefix                      :string(255)
#  postal_code                 :string(255)
#  lat                         :float
#  lng                         :float
#  utc_offset                  :float
#  json                        :text
#  created_at                  :datetime
#  updated_at                  :datetime
#

