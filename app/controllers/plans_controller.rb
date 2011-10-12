class PlansController < ApplicationController

  before_filter :require_current_user

  def index
    @plans = Plan.all
  end

  def show
    @plan = Plan.find(params[:id])
  end

  def new
    @plan = Plan.new
  end

  def create
    @plan = current_user.plans.new(params[:plan])

    if @plan.save
      flash[:notice] = 'Plan was successfully created.'
      redirect_to(@plan)
    else
      render :action => "new"
    end
  end

  def edit
    @plan = Plan.find(params[:id])
  end

  def update
    @plan = Plan.find(params[:id])

    if @plan.update_attributes(params[:plan])
      flash[:notice] = 'Plan was successfully updated.'
      redirect_to(@plan)
    else
      render :action => "edit"
    end
  end

  def destroy
    @plan = Plan.find(params[:id])
    @plan.destroy

    redirect_to(plans_url)
  end

end
