class FacebookController < ApplicationController
  
  def authorize
    @invitation = PlanUserInvitation.find_by_request_id(params[:request_id])
    @plan = Plan.find_by_uuid(@invitation.uuid) 
  end

  def ajax_request_handler
    @plan = PlanUserInvitation.create!(:request_id => params[:request], :uuid => params[:uuid])
    @plan.save
  end

end
