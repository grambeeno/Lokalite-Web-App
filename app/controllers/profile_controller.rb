class ProfileController < ApplicationController

  before_filter :authenticate_user!

  def datebook
    @saved_events = current_user.events.upcoming
    @plan = Plan.new
  end

  def plans
  end

  def friends
  end

end
