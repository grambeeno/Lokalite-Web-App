class LocationContextJoin < ActiveRecord::Base
  belongs_to :location
  belongs_to :context, :polymorphic => true
end

# == Schema Information
#
# Table name: location_context_joins
#
#  id           :integer         not null, primary key
#  location_id  :integer
#  context_type :string(255)
#  context_id   :integer
#  kind         :string(255)
#

