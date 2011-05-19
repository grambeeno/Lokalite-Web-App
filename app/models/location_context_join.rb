class LocationContextJoin < ActiveRecord::Base
  belongs_to :location
  belongs_to :context, :polymorphic => true
end
