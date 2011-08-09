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
    # @organization = Organization.new
    @organization = current_user.organizations.build
    @organization.email = current_user.email
    # @organization.image = Image.new

    # interface = '/organizations/new'
    # @image_cache = ImageCache.for(request.params, Dao.name_for(interface, :image))

    # if request.get?
    #   @result = api.read(interface, params)
    #   render_dao(@result)
    # else
    #   if params['/organizations/new(address)'].nil?  || params['/organizations/new(address)'].empty?
    #     params['/organizations/new(address)'] = Location.assemble_address(params)
    #   end
    #   @result = api.write(interface, params)

    #   if @result.valid?
    #     @image_cache.clear!
    #     message("Yay - You're ready to create an event!", :class => :success)
    #     id = @result.data.id
    #     redirect_to(my_organization_path(:id => id, :action => :new_event))
    #   else
    #     render_dao(@result)
    #   end
    # end
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

##
#
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

##
#
  def statuses
    @organization = Organization.find(@organization_id)
    @statuses = @organization.statuses.limit(10).order('created_at desc')

    if request.post?
      status = params[:status]
      @organization.set_status!(status) unless status.blank?
      message('New status set!', :class => :success)
      #redirect_to(:action => :status)
      #return
    end
  end

##
#
# TODO - support pagination here...
#
  def manage
    @organization = Organization.find(@organization_id)
    @events = @organization.events.limit(100).order('created_at desc')

    unless params[:status].blank?
      @organization.set_status!(params[:status])
      redirect_to(fullpath) and return
    end

    @statuses = @organization.statuses.limit(100).order('created_at desc')
  end

private
  def set_organization_id
    id = params[:organization_id] || params[:id]
    if id
      @organization_id = id
    end
  end
end
