class ProfileController < ApplicationController

  before_filter :authenticate_user!

  def plans
    @plans = current_user.plans.upcoming
  end

  def update
    params[:user].delete(:password) if params[:user][:password] && params[:user][:password].blank?

    if params[:updated_categories] == "changed"
      redirection_path = events_path(:origin => params[:origin], :category => 'suggested')
    else 
      redirection_path = :back
    end 
    
    if current_user.update_attributes(params[:user])
      flash[:success] = 'Your profile has been updated.'
      redirect_to redirection_path 
    else
      render :profile
    end
  end
end
