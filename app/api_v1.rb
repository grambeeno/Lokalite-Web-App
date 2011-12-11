ApiV1 =
  Dao.api do

    interface('/ping') do
      data.update :time => Time.now
    end

    interface('/profile') do
      data(current_user.to_dao)
    end

    interface('/places/') do
      read do
        organizations = Organization.browse(params)
        data!(:list => organizations.to_dao) unless organizations.empty?
      end
    end

    interface('/events/') do
      read do
        events = Event.browse(params)
        list = events.map{|event| event.to_dao(:for_user => current_user)}
        data!(:list => list)
      end
    end

    interface('/events/show') do
      id = params[:event_id] || params[:id]

      read do
        joins = []
        includes = [:categories, :image, :organization]
        event = Event.where(:id => params[:id]).joins(joins).includes(includes).first

        if event
          data!(event.to_dao)
        else
          status(404)
        end
      end
    end

    # the dao router has a problem with taking more than one route with an embeded param
    # I looked into it but it was taking too long, so we'll just pass ?event_id= instead
    interface('/events/trend') do
      write do
        event = Event.find(params[:event_id])
        if user_signed_in?
          current_user.events << event
        else
          @session[:trended_events] = [] unless @session[:trended_events]
          @session[:trended_events] << event.id
          event.anonymous_trend_count = event.anonymous_trend_count.to_i + 1
        end
        event.save

        # for some reason passing the current user was returning
        # "trended": null in the json. I tried reloading the event and user
        # but it didn't seem to help. We'll merge in the hardcoded value instead.
        #
        # data(event.to_dao(:for_user => current_user))

        data(event.to_dao.merge(:trended? => true))
      end
    end

    interface('/events/untrend') do
      write do
        event = Event.find(params[:event_id])
        if user_signed_in?
          current_user.events.remove(event)
        else
          @session[:trended_events].delete(event.id) if @session[:trended_events]
          event.anonymous_trend_count = event.anonymous_trend_count.to_i - 1
        end
        event.save

        data(event.to_dao.merge(:trended? => false))
      end
    end


  # utils
  #
    def parameter(name, options = {})
      options = Map.options(options)

      keys = [options[:key], options[:keys], options[:or]].compact
      keys.push(Array(name)) if keys.empty?

      value = nil
      got = false

      keys.each do |key|
        if params.key?(key)
          value = params.get(key)
          got = true
          break
        end
      end

      unless got
        candidates = keys.map{|key| key.inspect}.join(' or ')
        errors.add("None of #{ candidates } specified")
        status(:precondition_failed)
        return!
      end

      value
    end


  ## this is simply a suggest way to model your api.  it is not required.
  #
    attr_accessor :effective_user

    def initialize(current_user = nil)
      @current_user = current_user
    end

    def user_for(arg)
      User.find(arg)
    end

    def api
      self
    end

    def user_signed_in?
      !!@current_user
    end

    def current_user
      @current_user
    end

    def user?
      user_signed_in?
    end

    def my
      effective_user
    end

    def require_effective_user!
      unless effective_user
        status :unauthorized
        return!
      end
    end
    alias_method('require_user!', 'require_effective_user!')

    def require_organization!
      require_effective_user!
      @organization = user.organizations.where(:id => (params[:organization_id] || params[:id])).first
      unless @organization
        status :precondition_failed
        return!
      end
    end

    def require_organization_event!
      require_effective_user!
      require_organization!
      @event = Event.where(:organization_id => @organization.id, :id => (params[:event_id] || params[:id])).first
      unless @event
        status :precondition_failed
        return!
      end
    end

    def organization
      @organization
    end

    def ensure_io_or_url!(*args)
      args.each do |key|
        value = data.get(key)
        unless value.respond_to?(:read)
          if value.to_s =~ %r|^\w+://|
            update(key => openuri(value))
          end
        end
      end
    end

    def openuri(uri)
      OpenURI.open_uri(uri)
    end
  end

unloadable(ApiV1)
