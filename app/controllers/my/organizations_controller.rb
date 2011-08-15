class My::OrganizationsController < My::Controller
  before_filter :set_organization_id

##
#
  def index
    @organizations = current_user.organizations.order('name')

    if @organizations.empty?
      message('Please create an organization so you can start listing events!')
      redirect_to(:action => :new)
    end
  end

##
#
  def new
    @organization = current_user.organizations.build
    @organization.email = current_user.email
    # @organization.locations.build(:region => 'Colorado')
  end

  def edit
    @organization = Organization.find(params[:id])
    @organization.locations = @organization.locations.map{|l| l.set_address_components_for_editing }
  end

  def create
    @organization = Organization.new(params[:organization])

    if @organization.save
      current_user.organizations << @organization
      flash[:notice] = 'Organization was successfully created.'
      redirect_to(organization_path(@organization.slug, @organization.id))
    else
      logger.debug { "----------------- @organization #{@organization.errors.inspect}" }
      render :action => "new"
    end
  end

  def update
    @organization = Organization.find(params[:id])

    if @organization.update_attributes(params[:organization])
      flash[:notice] = 'Organization was successfully updated.'
      redirect_to(organization_path(@organization.slug, @organization.id))
    else
      render :action => "edit"
    end
  end

  def destroy
    @organization = Organization.find(params[:id])
    @organization.destroy

    redirect_to(organizations_url)
  end

  # def edit
  #   interface = '/organizations/edit'
  #   @image_cache = ImageCache.for(request.params, Dao.name_for(interface, :image))
  #   if request.get?
  #     @result = api.read(interface, params)
  #     render_dao(@result)
  #   else
  #     @result = api.write(interface, params)
  #     if @result.valid?
  #       @image_cache.clear!
  #       name = @result.data.name
  #       id = @result.data.id
  #       message("Your updates to #{ name.inspect } have been saved!", :class => :success)
  #       #redirect_to(my_organization_path(:id => id, :action => :new_event))
  #       redirect_to(my_organization_path())
  #     else
  #       render_dao(@result)
  #     end
  #   end
  # end

  def new_event
    interface = '/organizations/new/event'
    @image_cache = ImageCache.for(request.params, Dao.name_for(interface, :image))

    @organization_id = params[:organization_id] || params[:id]
    if @organization_id
      key = Dao.name_for(interface, :organization_id)
      params[key] = @organization_id
    end

    if request.get?
      @result = api.read(interface, params)
      render_dao(@result)
    else
      @result = api.write(interface, params)

      if @result.valid?
        @image_cache.clear!
        name = h(@result.data.name.inspect)
        clone_count = @result.data.get(:clone_count)
        if clone_count
          message("The event #{ name }, along with #{ clone_count } repeating events, have been created!", :class => :success)
        else
          message("The event #{ name } has been created!", :class => :success)
        end
        id = @result.data.id
        redirect_to(event_path(:id => id))
      else
        render_dao(@result)
      end
    end
  end

  def edit_event
    interface = '/organizations/edit/event'
    @image_cache = ImageCache.for(request.params, Dao.name_for(interface, :image))

    #@organization_id = params[:organization_id] || params[:id]
    #if @organization_id
      #key = Dao.name_for(interface, :organization_id)
      #params[key] = @organization_id
    #end

    if request.get?
      @result = api.read(interface, params)
      render_dao(@result)
    else
      @result = api.write(interface, params)

      if @result.valid?
        @image_cache.clear!
        name = h(@result.data.name.inspect)
        #clone_count = @result.data.get(:clone_count)
        #if clone_count
          #message("The event #{ name }, along with #{ clone_count } repeating events, have been created!", :class => :success)
        #else
          message("The event #{ name } has been updated!", :class => :success)
        #end
        id = @result.data.id
        redirect_to(event_path(:id => id))
      else
        render_dao(@result)
      end
    end
  end

private
  def set_organization_id
    id = params[:organization_id] || params[:id]
    if id
      @organization_id = id
    end
  end
end
