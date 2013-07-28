class My::OrganizationsController < My::Controller

  before_filter :find_organization_and_authorize

  def show
    @repeating_events = @organization.events.repeating.prototypes.by_date
    @one_time_events = @organization.events.upcoming.one_time
  end

  def index
    if params[:all] == 'true' && current_user.event_admin?
      @organizations = Organization.order('name')
    else
      @organizations = current_user.organizations.order('name')
    end

    if @organizations.empty?
      message('Please create an organization so you can start listing events!')
      redirect_to(:action => :new)
    end
  end

  def new
    @organization = current_user.organizations.build
    @organization.email = current_user.email
    @organization.locations.build(:region => 'CO')
  end

  def edit
  end

  def create
    @organization = Organization.new(params[:organization])

    if @organization.save
      current_user.organizations << @organization
      flash[:notice] = 'Organization was successfully created.'
      redirect_to(organization_path(@organization.slug, @organization.id))
    else
      render :action => "new"
    end
  end

  def update
    if @organization.update_attributes(params[:organization])
      flash[:notice] = 'Organization was successfully updated.'
      redirect_to(organization_path(@organization.slug, @organization.id))
    else
      render :action => "edit"
    end
  end

  def destroy
    @organization.destroy

    redirect_to(organizations_url)
  end

  def add_user
    if request.post?
      address = params[:email_address].strip
      if  address.present? && user = User.find_by_email(address)
        @organization.users << user

        flash[:success] = "#{address} now has access to this organization."
        redirect_to organization_path(@organization.slug, @organization.id)
      else
        flash[:error] = "Sorry, we couldn't find an account for \"#{address}\". Please make sure they are signed up and enter their email address exactly."
        redirect_to :back
      end
    end
  end

  def remove_user
    if request.post?
      address = current_user.email 
      organization = @organizations
      name = @organization.name 
      if  address.present? && user = User.find_by_email(address)
        @organization.users.delete(user)

        flash[:success] = "#{address} has been removed from #{name}."
        redirect_to edit_profile_path
      else
        flash[:error] = "Sorry, we couldn't find #{address} for #{organization}." #address and organization still doesn't work
        redirect_to :back
      end
    end
  end

  private

  def find_organization_and_authorize
    id = params[:id] || params[:organization_id]
    @organization = Organization.find(id) if id
    if @organization
      permission_denied unless @organization.users.include?(current_user) || current_user.event_admin?
    end
  end

end
