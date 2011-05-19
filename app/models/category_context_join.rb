class CategoryContextJoin < ActiveRecord::Base
  belongs_to :category
  belongs_to :context, :polymorphic => true
end
