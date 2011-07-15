class UserRoleJoin < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
end

# == Schema Information
#
# Table name: user_role_joins
#
#  id         :integer         not null, primary key
#  role_id    :integer
#  user_id    :integer
#  primary    :boolean         default(TRUE)
#  created_at :datetime
#  updated_at :datetime
#

