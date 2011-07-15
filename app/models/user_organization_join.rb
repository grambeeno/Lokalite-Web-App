class UserOrganizationJoin < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization
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

