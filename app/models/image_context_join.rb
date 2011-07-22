class ImageContextJoin < ActiveRecord::Base
  belongs_to :image
  belongs_to :context, :polymorphic => true
end

# == Schema Information
#
# Table name: image_context_joins
#
#  id           :integer         not null, primary key
#  image_id     :integer
#  context_type :string(255)
#  context_id   :integer
#  kind         :string(255)
#

