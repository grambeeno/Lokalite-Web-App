class VenueContextJoin < ActiveRecord::Base
  belongs_to :venue
  belongs_to :context, :polymorphic => true
end
