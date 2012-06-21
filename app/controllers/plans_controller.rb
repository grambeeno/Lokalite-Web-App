class PlansController < ApplicationController

  before_filter :authenticate_user!, :except => :show
  before_filter :find_plan

  def index
    redirect_to user_plans_path
  end

  def show
    if params[:invitation] #and !user_signed_in?
      session[:plan_invitation_uuid] = params[:id]
    end
  end

  def accept_invitation
    current_user.accepted_invitations.create(:plan_id => @plan.id)
    redirect_to @plan, :success => 'Glad you can be there!'
  end

  def new
    @saved_events = current_user.events.upcoming
    @plan = Plan.new
  end

  def create
    @plan = current_user.plans.new(params[:plan])

    if @plan.save
      current_user.accepted_invitations.create(:plan_id => @plan.id)

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
