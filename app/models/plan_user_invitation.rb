class PlanUserInvitation < ActiveRecord::Base
  belongs_to :plan
  belongs_to :user

  scope :accepted, where(:accepted => true)
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
#  request_id :string(255)
#  uuid       :string(255)
#

