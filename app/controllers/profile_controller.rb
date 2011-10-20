class ProfileController < ApplicationController

  before_filter :authenticate_user!

  def datebook
    @saved_events = current_user.events.upcoming
    @plan = Plan.new
  end

  def plans
    @plans = current_user.plans.upcoming
  end

  def update
    params[:user].delete(:password) if params[:user][:password] && params[:user][:password].blank?

    if current_user.update_attributes(params[:user])
      flash[:success] = 'Your profile has been updated.'
      redirect_to :back
    else
      render :profile
    end
  end
end
