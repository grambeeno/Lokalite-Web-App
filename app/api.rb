Api = 
  Dao.api do

    interface('/ping') do
      data.update :time => Time.now
    end

    interface('/profile') do
      data(current_user.to_dao)
    end

  # organization/new
  #
    # interface('/organizations/new') do
    #   require_user!
    # 
    #   params[:email] = current_user ? current_user.email : ''
    #   
    #   read do
    #   end
    # 
    #   write do
    #     data(params)
    # 
    #     validates_length_of(:name, :in => (2..64))
    #     validates_word_count_of(:description, :in => (4..420))
    #     validates_as_location(:address)
    #     validates_as_email(:email)
    #     validates_as_url(:url)
    #    # validates_as_phone(:phone)
    #     validates_presence_of(:address)
    #     validates_presence_of(:category)
    #     validates_presence_of(:image, :allow_nil => false, :allow_blank => false)
    # 
    #     validate!
    # 
    #     ensure_io_or_url!(:image)
    # 
    #     transaction do
    # 
    #       organization = Organization.new
    #       organization.users.add(current_user)
    #       organization.name        = data.name
    #       organization.description = data.description
    #       organization.email       = data.email
    #       organization.url         = data.url
    #       organization.phone       = data.phone
    #       organization.address     = data.address
    #       organization.save!
    #       organization.reload
    # 
    #       category = Category.for(data.category)
    # 
    #       venue = Organization.default_venue_for(organization)
    #       venue.save!
    # 
    #       image = Image.for(data.image)  
    #       image.save! unless image.nil?
    # 
    #       organization.category = category
    #       organization.venue = venue
    #       organization.image = image
    #       organization.save!
    # 
    #       data!(organization.to_dao(:name, :description, :email, :url, :phone, :category, :venue))
    #     end
    #   end
    # end

  # organization/edit
  #
    # interface('/organizations/edit') do
    #   require_user!
    #   id = parameter(:organization_id, :or => :id)
    # 
    #   read do
    #     transaction do
    #       organization = my.organizations.find(id)
    #       data.update(organization.to_dao)
    #       data.update(:category => organization.category.to_dao)
    #       data.update(:venue => organization.venue.to_dao)
    #       if data.has_key?'image' and !data['image'].nil?
    #         data.update(:image => organization.image.to_dao(:id, :basename, :url))
    #       end 
    #     end
    #   end
    # 
    #   write do
    #     data(params)
    #     validates_length_of(:name, :in => (2..64))
    #     validates_word_count_of(:description, :in => (4..420))
    #     validates_as_location(:address)
    #     validates_as_email(:email)
    #     validates_as_url(:url)
    #    # validates_as_phone(:phone)
    #     validates_presence_of(:address)
    #     validates_presence_of(:category)
    #     #Given:must be an image to do initial save, so there IS an image.
    #     #Unless user clicks accept/Choose button during EDIT, nothing comes back in params, 
    #     #so ignore the absence of image during EDIT.
    #     validates_presence_of(:image, :allow_nil => false, :allow_blank => false) if data.has_key?'image'
    # 
    #     validate!
    #     ensure_io_or_url!(:image) if data.has_key?'image'
    # 
    #     transaction do
    #       organization = Organization.find(id)
    # 
    #       unless my.organizations.include?(organization)
    #         status(:unauthorized)
    #         return!
    #       end
    # 
    #       organization.name = data.name
    #       organization.description = data.description
    #       organization.email = data.email
    #       organization.url = data.url
    #       organization.phone = data.phone
    #       organization.address = data.address
    #       organization.save!
    #       organization.reload
    # 
    #       category = Category.for(data.category)
    #       organization.category = category
    #       organization.save!
    # 
    #       if data.has_key?'image'
    #         image = Image.for(data.image)
    #         image.save!
    #         organization.image = image
    #         organization.save!
    #       end
    # 
    #       data.update(organization.to_dao)
    #       data.update(:category => organization.category.to_dao)
    #       data.update(:venue => organization.venue.to_dao)
    #       if data.has_key?'image' and !data['image'].nil?
    #         data.update(:image => organization.image.to_dao(:id, :basename, :url))
    #       end
    #     end
    #   end
    # end

  # organizations/my
  # 
    # interface('/organizations/my') do
    #   require_user!
    # 
    #   read do
    #     joins = []
    #     includes = []
    #     where = {}
    # 
    #     records = my.organizations.joins(joins).includes(includes).where(where)
    # 
    #     list = records.map{|record| record.attributes} 
    # 
    #     update :list => list
    #   end
    # end

  # organization/new/event
  #
    # interface('/organizations/new/event') do
    #   require_user!
    #   require_organization!
    # 
    #   data(params)
    # 
    #   today = Date.today
    #   tomorrow = today + 1
    # 
    #   params[:starts_at] = {
    #     :date => tomorrow,
    #     :time => '6pm'
    #   }
    #   params[:ends_at] = {
    #     :date => tomorrow,
    #     :time => '10pm'
    #   }
    # 
    #   data.update(:organization => organization)
    # 
    #   read do
    #   end
    # 
    #   write do
    #     validates_length_of(:name, :in => (2..64))
    #     validates_word_count_of(:description, :in => (4..420))
    #     validates_presence_of(:starts_at)
    #     validates_presence_of(:category)
    #     #TTD should probably use the org's image if empty?
    #     validates_presence_of(:image, :allow_nil => false, :allow_blank => false)
    #     
    #     validates(:venue) do |value|
    #       if value.blank?(:id)
    #         if value.blank?(:name) and value.blank?(:address)
    #           errors.add "Please create a new venue if you are not selecting an existing one"
    #         end
    #       else
    #         unless value.blank?(:name) and value.blank?(:address)
    #           errors.add "Please don't select a venue if you really want to create a new one"
    #         end
    #       end
    #     end
    # 
    # 
    #     validate!
    #     ensure_io_or_url!(:image) 
    # 
    #     transaction do
    #       venue =
    #         unless data.blank?(:venue, :id)
    #           id = data.get(:venue, :id)
    #           organization.venues.find(id)
    #         else
    #           name = data.get(:venue, :name)
    #           email = data.get(:venue, :email)
    #           phone = data.get(:venue, :phone)
    #           address = data.get(:venue, :address)
    #           organization.venues.create!(:name => name, :address => address, :email => email, :phone => phone)
    #         end
    #       raise unless venue
    # 
    #       starts_at = venue.location.time_for([data.get(:starts_at, :date), data.get(:starts_at, :time)].join(' '))
    #       ends_at = venue.location.time_for([data.get(:ends_at, :date), data.get(:ends_at, :time)].join(' '))
    #       #ends_at = starts_at + 1.hour unless ends_at > starts_at
    # 
    #       unless ends_at > starts_at
    #         msg = 'Your event cannot end before it starts!'
    #         ends_at.to_date == starts_at.to_date ? errors.add(:ends_at, :time, msg) : errors.add(:ends_at, :date, msg)
    #         return!
    #       end
    # 
    #       category = Category.for(data.category)
    # 
    #       image = Image.for(data.image) 
    #       image.save! if !image.nil?
    # 
    #       event = Event.new
    #       event.name = data.name
    #       event.description = data.description
    #       event.starts_at = starts_at
    #       event.ends_at = ends_at
    #       event.all_day = data.blank?(:all_day) ? false : true
    #       event.repeats = data.get(:repeats)
    #       event.save!
    # 
    #       event.organization = organization
    #       event.category = category
    #       event.image = image if !image.nil?
    #       event.venue = venue
    #       
    #       event.save!
    #       event.index!
    # 
    #       dao = event.to_dao
    #  
    #       # Causing a PROD crash - June 10, '11
    #       # unless data.blank?(:repeats)
    #       #   frequency = data.get(:repeats)
    #       #   events = event.repeat!(frequency)
    #       #   dao.update(:clone_count => events.size)
    #       # end
    # 
    #       data!(dao)
    #     end
    #   end
    # end

  # organization/edit/event
  #
    # interface('/organizations/edit/event') do
    #   require_user!
    #   require_organization!
    #   require_organization_event!
    # 
    #   if @event.prototype_id
    #     @event = @event.prototype
    #   end
    # 
    #   read do
    #     transaction do
    #       data.update(@event.to_dao)
    #       params.merge!(@event.to_dao)
    # 
    #       date = @event.venue_time(:starts_at).to_date.to_s
    #       time =  @event.venue_time(:starts_at).strftime('%H:%M')
    #       data.set :starts_at, :date => date, :time => time
    # 
    #       date = @event.venue_time(:ends_at).to_date.to_s
    #       time =  @event.venue_time(:ends_at).strftime('%H:%M')
    #       data.set :ends_at, :date => date, :time => time
    # 
    #       data.update(:category => @organization.category.to_dao)
    #       data.update(:organization => @organization.to_dao)
    #       data.update(:venue => @organization.venue.to_dao(:id))
    #       data.update(:image => @event.image.to_dao(:id, :basename, :url)) 
    #     end
    #   end
    # 
    # 
    #   write do
    #     data(params)
    # 
    #     validates_length_of(:name, :in => (2..64))
    #     validates_word_count_of(:description, :in => (4..420))
    #     validates_presence_of(:starts_at)
    #     #validates_presence_of(:category)
    #     validates_presence_of(:image, :allow_nil => false, :allow_blank => false)
    # 
    #     validate!
    #     ensure_io_or_url!(:image)
    #     #
    # 
    # 
    #     transaction do
    # 
    #     # nuke all the children
    #     #
    #       @event.clones.map{|clone| clone.destroy}
    # 
    #     # determine the venue
    #     #
    #       venue =
    #         unless data.blank?(:venue, :id)
    #           id = data.get(:venue, :id)
    #           organization.venues.find(id)
    #         else
    #           name = data.get(:venue, :name)
    #           email = data.get(:venue, :email)
    #           phone = data.get(:venue, :phone)
    #           address = data.get(:venue, :address)
    #           organization.venues.create!(:name => name, :address => address, :email => email, :phone => phone)
    #         end
    #       raise unless venue
    # 
    #   # map datetimes into the venue space
    #   #
    #       starts_at = venue.location.time_for([data.get(:starts_at, :date), data.get(:starts_at, :time)].join(' '))
    #       ends_at = venue.location.time_for([data.get(:ends_at, :date), data.get(:ends_at, :time)].join(' '))
    #       #ends_at = starts_at + 1.hour unless ends_at > starts_at
    # 
    #       unless ends_at > starts_at
    #         msg = 'Your event cannot end before it starts!'
    #         ends_at.to_date == starts_at.to_date ? errors.add(:ends_at, :time, msg) : errors.add(:ends_at, :date, msg)
    #         return!
    #       end
    # 
    #   # determine the category
    #   #
    #       category = Category.for(data.category)
    # 
    #       image = nil
    #       if data.has_key?'image'
    #         ensure_io_or_url!(:image)
    #         image = Image.for(data.image)
    #         image.save!
    #       end
    # 
    #       @event = Event.find(@event.id)
    #       @event.name = data.name
    #       @event.description = data.description
    #       @event.starts_at = starts_at
    #       @event.ends_at = ends_at
    #       @event.all_day = data.blank?(:all_day) ? false : true
    #       @event.repeats = data.get(:repeats)
    #       @event.save!
    #       @event.reload
    # 
    #       #event.organization = organization
    #       @event.category = category if category
    #       @event.image = image if image
    #       @event.venue = venue if venue
    #       
    #       @event.save!
    #       @event.index!
    # 
    #       # Causing a PROD crash - June 10, '11
    #       # unless data.blank?(:repeats)
    #       #   frequency = data.get(:repeats)
    #       #   events = @event.repeat!(frequency)
    #       #   data.update(:clone_count => events.size)
    #       # end
    # 
    #       data.update(@event.to_dao)
    # 
    #       date = @event.starts_at.to_date.to_s
    #       time =  @event.starts_at.strftime('%H:%M')
    #       data.set :starts_at, :date => date, :time => time
    # 
    #       date = @event.ends_at.to_date.to_s
    #       time =  @event.ends_at.strftime('%H:%M')
    #       data.set :ends_at, :date => date, :time => time
    # 
    # 
    #       data.update(:category => @organization.category.to_dao)
    #       data.update(:organization => @organization.to_dao)
    #       data.update(:venue => @organization.venue.to_dao(:id))
    #       if data.has_key?'image' and !data['image'].nil?
    #         data.update(:image => @organization.image.to_dao(:id, :basename, :url))
    #       end
    # 
    #       validate!
    #     end
    #   end
    # end

    interface('/organizations/browse') do

      read do
        organizations = Organization.browse(params)
        data!(:list => organizations.to_dao) unless organizations.empty?
      end
    end

    interface('/events/browse') do
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
        includes = [:venue, {:venue => :location}, :category, :image, :organization]
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
    interface('/events/trend/') do
      write do
        event = Event.find(params[:event_id])
        current_user.events << event

        # for some reason passing the current user was returning
        # "trended": null in the json. I tried reloading the event and user
        # but it didn't seem to help. We'll merge in the hardcoded value instead.
        #
        # data(event.to_dao(:for_user => current_user))

        data(event.to_dao.merge(:trended? => true))
      end
    end
    
    interface('/events/untrend/') do
      write do
        event = Event.find(params[:event_id])
        current_user.events.remove(event)
        # data(event.to_dao(:for_user => current_user))
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

    # def validates_as_location(*args)
    #   options = Dao.options_for!(args)
    # 
    #   message = options[:message] || "ambiguous address"
    # 
    #   allow_nil = options[:allow_nil]
    #   allow_blank = options[:allow_blank]
    # 
    #   block =
    #     lambda do |value|
    #       map = Dao.map(:valid => true)
    # 
    #       if value.nil? and allow_nil
    #         map[:valid] = true
    #         throw(:valid, map)
    #       end
    # 
    #       value = value.to_s.strip
    # 
    #       if value.empty? and allow_blank
    #         map[:valid] = true
    #         throw(:valid, map)
    #       end
    # 
    #       addresses = Location.pinpoint(value)
    # 
    #       case addresses.size
    #         when 0
    #           map[:valid] = false
    #           throw(:valid, map)
    #         when 1
    #           nil
    #         else
    #           map[:valid] = false
    #           map[:message] = addresses.join(' | ')
    #           throw(:valid, map)
    #       end
    # 
    #       map
    #     end
    # 
    #   args.push(:message => message)
    #   validates(*args, &block)
    # end

  ## this is simply a suggest way to model your api.  it is not required.
  #
    attr_accessor :effective_user
    attr_accessor :real_user

    def initialize(*args)
      options = args.extract_options!.to_options!
      effective_user = args.shift || options[:effective_user] || options[:user]
      real_user = args.shift || options[:real_user] || effective_user
      @effective_user = user_for(effective_user) if effective_user
      @real_user = user_for(real_user) if real_user
      @real_user ||= @effective_user
    end

    def user_for(arg)
      User.find(arg)
    end

    alias_method('user', 'effective_user')
    alias_method('user=', 'effective_user=')
    alias_method('current_user', 'effective_user')
    alias_method('current_user=', 'effective_user=')

    def api
      self
    end

    def logged_in?
      @effective_user and @real_user
    end

    def user?
      logged_in?
    end

    def current_user
      effective_user
    end

    def current_user?
      !!effective_user
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


unloadable(Api)

def api(*args, &block)
  Api.new(*args, &block)
end
