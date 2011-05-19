class ImageContextJoin < ActiveRecord::Base
  belongs_to :image
  belongs_to :context, :polymorphic => true
end
