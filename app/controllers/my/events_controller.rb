class My::EventsController < My::Controller
  def new
    @organizations = current_user.organizations

    if @organizations.empty?
      message("Please create your first organization and then create an event!", :class => :error)
      redirect_to(my_organizations_path(:new))
      return
    end

    @organization = Organization.find(params[:organization_id])
    @event = Event.new
  end
end
