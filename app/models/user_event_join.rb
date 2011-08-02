class UserEventJoin < ActiveRecord::Base
  belongs_to :user
  belongs_to :event, :counter_cache => :users_count
end

# == Schema Information
#
# Table name: user_event_joins
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  event_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

