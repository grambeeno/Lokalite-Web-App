class FacebookController < ApplicationController
  
  def index
    unless params[:request_id].nil?
      @invitation = PlanUserInvitation.find_by_request_id(params[:request_id])
      @plan = Plan.find_by_uuid(@invitation.uuid) 
      redirect_to(@plan)
    end
  end

  def ajax_request_handler
    @plan = PlanUserInvitation.create!(:request_id => params[:request], :uuid => params[:uuid])
    @plan.save
  end

end
