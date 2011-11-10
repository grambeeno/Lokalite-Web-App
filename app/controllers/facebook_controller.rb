class FacebookController < ApplicationController
  
  def authorize
    request_ids = params[:request_ids].to_a
    if request_ids.count == 1
      @invitation = PlanUserInvitation.find_by_request_id(params[:request_ids])
      @plan = Plan.find_by_uuid(@invitation.uuid) 
    else
      # render :index
    end
  end

  def ajax_request_handler
    @plan = PlanUserInvitation.create!(:request_id => params[:request], :uuid => params[:uuid])
    @plan.save
    respond_to do |format| 
      format.js { render :json => @plan }
    end
  end

end
