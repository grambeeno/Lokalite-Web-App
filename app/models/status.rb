class Status < ActiveRecord::Base
  belongs_to :context, :polymorphic => true

  def to_s
    content
  end
end

# == Schema Information
#
# Table name: statuses
#
#  id           :integer         not null, primary key
#  context_type :string(255)
#  context_id   :integer
#  content      :text
#  created_at   :datetime
#  updated_at   :datetime
#

