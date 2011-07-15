class VenueContextJoin < ActiveRecord::Base
  belongs_to :venue
  belongs_to :context, :polymorphic => true
end

# == Schema Information
#
# Table name: venue_context_joins
#
#  id           :integer         not null, primary key
#  venue_id     :integer
#  context_type :string(255)
#  context_id   :integer
#  kind         :string(255)
#

