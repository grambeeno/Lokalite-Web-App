class PlansController < ApplicationController

  before_filter :authenticate_user!, :except => :show
  before_filter :find_plan

  def index
    redirect_to user_plans_path
  end

  def show
    if params[:invitation]
      if user_signed_in?
        # give the user a plan invitation, display to them the option of accepting the invitation
      else
        session[:plan_invitation_uuid] = params[:id]
        flash[:success] = "You've been invited to join this plan!<br /><br />To accept this invitation, please <a href='/users/sign_in'>Sign In</a> or <a href='/users/sign_up'>Sign Up</a>."
      end
    end
  end

  def new
    @saved_events = current_user.events.upcoming
    @plan = Plan.new
  end

  def create
    @plan = current_user.plans.new(params[:plan])

    if @plan.save
      flash[:notice] = 'Plan was successfully created.'
      redirect_to(@plan)
    else
      @saved_events = current_user.events.upcoming
      render :action => "new"
    end
  end

  def edit
    authorize_edit
    @saved_events = current_user.events.upcoming
  end

  def update
    authorize_edit

    if @plan.update_attributes(params[:plan])
      flash[:notice] = 'Plan was successfully updated.'
      redirect_to(@plan)
    else
      @saved_events = current_user.events.upcoming
      render :action => "edit"
    end
  end

  def destroy
    authorize_edit
    @plan.destroy

    redirect_to(plans_url)
  end

  private

  def find_plan
    id = params[:id]
    @plan = Plan.find_by_uuid(id) if id
  end

  def authorize_edit
    permission_denied unless @plan.user == current_user
  end

end
