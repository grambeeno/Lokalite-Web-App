class CategoryContextJoin < ActiveRecord::Base
  belongs_to :category
  belongs_to :context, :polymorphic => true
end

# == Schema Information
#
# Table name: category_context_joins
#
#  id           :integer         not null, primary key
#  category_id  :integer
#  context_type :string(255)
#  kind         :string(255)
#  context_id   :integer
#

