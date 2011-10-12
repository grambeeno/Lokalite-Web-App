class PlanUserInvitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :plan
end

# == Schema Information
#
# Table name: plan_user_invitations
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  plan_id    :integer
#  accepted   :boolean
#  created_at :datetime
#  updated_at :datetime
#

