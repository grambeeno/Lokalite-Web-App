class FacebookController < ApplicationController

  def authorize
    redirect_to root_path
    # request_ids = Array(params[:request_ids]).join(',').strip.split(/\\s*,\\s*/).last
    # @invitation = PlanUserInvitation.find_by_request_id(request_ids)
    # @plan = Plan.find_by_uuid(@invitation.uuid)
  end

  def ajax_request_handler
    @plan = PlanUserInvitation.create!(:request_id => params[:request], :uuid => params[:uuid])
    @plan.save
    respond_to do |format|
      format.js { render :json => @plan }
    end
  end

end
