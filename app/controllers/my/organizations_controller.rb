class My::OrganizationsController < My::Controller

  before_filter :find_organization_and_authorize

  def show
  end

  def index
    @organizations = current_user.organizations.order('name')

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

  private

  def find_organization_and_authorize
    @organization = Organization.find(params[:id]) if params[:id]
    if @organization
      permission_denied unless @organization.users.include?(current_user)
    end
  end

end
