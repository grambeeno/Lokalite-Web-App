class ApplicationController < ActionController::Base
  include Tagz.globally

  protect_from_forgery

  layout :layout_for_request

  before_filter :set_current_controller!
  before_filter :configure_default_url_options!
  before_filter :set_user_time_zone


protected

  def set_user_time_zone
    Time.zone = current_user.time_zone if logged_in?
  end

# be sure to keep flash on redirects
#
  def redirect_to(*a, &b)
    super
  ensure
    flash.keep
  end

  def meta_redirect_to(*args)
    options = args.extract_options!.to_options!
    url = url_for(*args)
    text = "<meta http-equiv='refresh' content='0;url=#{ CGI.escapeHTML(url) }'>"
    options[:text] ||= text
    render(options)
  end


# current user support
#
  def effective_user
    @effective_user ||= User.where(:uuid => session[:effective_user]).first
  end
  helper_method(:effective_user)

  def real_user
    @real_user ||= User.where(:uuid => session[:real_user]).first
  end
  helper_method(:real_user)

  def current_user
    effective_user
  end
  helper_method(:current_user)

  def user_sudoing?
    real_user != effective_user
  end
  helper_method(:user_sudoing?)

  def require_current_user
    unless current_user
      message("Sorry, you must be logged in to view #{ h(request.fullpath) }", :class => :error)
      redirect_to(login_path)
      return
    end
  end

  def require_admin_user
    unless real_user and real_user.admin?
      message("Sorry, you must be logged as an *admin* in to view #{ h(request.fullpath) }", :class => :error)
      redirect_to(login_path)
      return
    end
  end

  def logged_in?
    session[:real_user]
  end
  helper_method(:logged_in?)

# api support
#
  def api
    @api ||= Api.new(effective_user, real_user)
  end

# current controller support
#
  def set_current_controller!
    ApplicationController.current = self
  end
  def current_controller
    ApplicationController.current
  end
  helper_method(:current_controller)

  def current_action
    action_name
  end
  helper_method(:current_action)

# location support
#
  def current_location
    Location.where('prefix=?', current_location_prefix).first
  end
  helper_method :current_location

  def current_location_prefix
    #session[:location] = Location.default.prefix if session[:location].blank?
    #session[:location]
    @current_location_prefix ||= Location.absolute_path_for(params[:location])
  end
  helper_method :current_location_prefix

  def current_location_name
    parts = current_location_prefix.split('/')
    last = parts.last
    last.titleize if last
  end
  helper_method :current_location_name

# setup default_url_options
#
   def configure_default_url_options!
     DefaultUrlOptions.configure!(request)
   ensure
      def ApplicationController.configure_default_url_options!() end
   ### TODO - should be able to removed the filter but rails doesn't like it...
   end

# re-define local_request so that it does not lick the hairy ball sack
#
  def local_request?()
    return true if %w( development test ).include?(Rails.env)
    local = %w( 0.0.0.0 127.0.0.1 localhost localhost.localdomain )
    local.include?(request.remote_addr) and local.include?(request.remote_ip)
  end

# support for layout selection, automatic and manual via params.
#
  def default_layout_for_request
    return params[:__layout] if params[:__layout]
    return params[:layout] if params[:layout]
    'application'
  end

  def layout_for_request(*layout)
    @layout_for_request ||= default_layout_for_request
    unless layout.empty?
      @layout_for_request = layout.first.to_s
    end
    @layout_for_request
  end

  def partial?
    (params[:__layout] || params[:layout]) == 'partial'
  end
  helper_method 'partial?'

  def modal?
    (params[:__layout] || params[:layout]) == 'modal'
  end
  helper_method 'modal?'

# encrypt/decrypt support
#
  def encrypt(*args, &block)
    App.encrypt(*args, &block)
  end
  helper_method(:encrypt)

  def decrypt(*args, &block)
    App.decrypt(*args, &block)
  end
  helper_method(:decrypt)

# support for knowing which web server we're running behinde
#
  def ApplicationController.server_software
    @@server_software ||= ENV['SERVER_SOFTWARE']
  end
  def server_software
    ApplicationController.server_software
  end
  helper_method(:server_software)

  def ApplicationController.behind_apache?
    @@behind_apache ||= !!(server_software && server_software =~ /Apache/io)
  end
  def behind_apache?
    ApplicationController.behind_apache?
  end
  helper_method('behind_apache?')

  def ApplicationController.behind_nginx?
    @@behind_nginx ||= !!(server_software && server_software =~ /NGINX/io)
  end
  def behind_nginx?
    ApplicationController.behind_nginx?
  end
  helper_method('behind_nginx?')

# do the 'right thing' when sending files
#
  def x_sendfile(path, options = {})
    if behind_apache? or behind_nginx? or params['x_sendfile']
      headers['X-Sendfile'] = File.expand_path(path)
    end
    send_file(path, options)
  end

# server info support
#
# server info support
#
  def ApplicationController.server_info
    @@server_info_cache ||= {
      'hostname' => Socket.gethostname.strip,
      'git_rev' => `git rev-parse HEAD 2>/dev/null`.to_s.strip,
      'rails_env' => RAILS_ENV,
      'rails_stage' => defined?(RAILS_STAGE)&&RAILS_STAGE,
    }
=begin
    @@server_info_cache.merge(
      :controller => current_controller.class.name.underscore.sub(/_controller/,''),
      :action => current_action.to_s
    )
=end
    @@server_info_cache.merge(current_controller.send(:params).slice(:controller, :action))
  #rescue
    #@@server_info_cache = {}
  end
  def server_info
    ApplicationController.server_info
  end
  helper_method :server_info

  def ApplicationController.git_rev()
    server_info['git_rev']
  end
  def git_rev
    ApplicationController.git_rev
  end
  helper_method :git_rev

# support for in-app referrer (never cross site)
#
  def http_referer
    uri_path(request.env['HTTP_REFERER']) rescue '/'
  end
  alias_method 'http_referrer', 'http_referer'
  helper_method 'http_referer'
  helper_method 'http_referrer'

  def uri_path uri
    URI.parse(uri).path
  end
  helper_method 'uri_path'


# various html/form generation shortcuts
#
  def authenticity_token
    @authenticity_token || helper.form_authenticity_token
  end
  helper_method :authenticity_token

  def h(*args, &block)
    CGI.escapeHTML(*args, &block)
  end

  def fullpath
    request.fullpath
  end
  helper_method :fullpath

  def helper(&block)
    @helper ||= Helper.new(controller=self)
    block ? @helper.instance_eval(&block) : @helper
  end

  def link_to(arg, *args)
    if args.empty?
      helper {
        url = url_for(arg)
        link_to(url, url)
      }
    else
      helper{ link_to(arg, *args) }
    end
  end

  def style
    @style ||= (
      Map.new{|m,k| m[k] = Map.new}
    )
  end
  helper_method :style

# flash/message support
#
  def flash_message_keys()
    @flash_keys ||= [:info, :notice, :error, :success]
  end
  helper_method(:flash_message_keys)

  def message(*args)
    options = args.extract_options!.to_options!
    string = args.shift
    if string and not args.empty?
      string = string % args
    end
    type = (options[:type] || options[:class]).to_s
    type = :notice if type.blank?
    key = type.to_s.to_sym
    if flash[key]
      flash[key] = flash[key].to_s + '<br /><br />' + string.to_s
    else
      flash[key] = string.to_s
    end
  end
  helper_method(:message)

  def json_for(object)
    object = object.attributes if object.is_a?(ActiveRecord::Base)
    if Rails.env.production?
      ::JSON.generate(object)
    else
      ::JSON.pretty_generate(object, :max_nesting => 0)
    end
  end
  helper_method(:to_json)

  def render_object(object, options = {})
    options.to_options!

    json = json_for(object)
    json.gsub!(/\n/, '<br/>')
    json.gsub!(' ', '&nbsp;')

    options[:text] = json
    options[:layout] = 'application' unless options.has_key?(:layout)
    render(options)
  end

# path helpers
#
  def browse_directory_path(options = {})
    options.to_options!
    context = (defined?(@context) ? @context : {}).to_options!

    query = {}

    organization = options[:organization] || context[:organization]
    if organization
      organization = Organization.find(organization) unless organization.is_a?(Organization)
    end

    location = options[:location] || context[:location] || (organization ? organization.location : default_location)
    location = location.prefix if location.respond_to?(:prefix)

    category = options[:category] || context[:category]
    category = category.name if category.respond_to?(:name)
    category = category.parameterize('_') if category
    #date = options[:date] || context[:date]

    keywords = options[:keywords]
    order = options[:order]
    page = options[:page]
    per_page = options[:per_page]

    #organization = organization.id if organization.is_a?(Organization)
    #date = Slug.for(date) if date

    path = []
    path.push("/directory")

    #if(location and options[:location] != false)
    if(organization.blank?)
      path.push("/location/#{ location }") unless location.blank?
      path.push("/category/#{ category }") unless(category.blank? or category =~ /^All$/i)
      #path.push("/date/#{ date }") unless(date.blank? or date =~ /^All$/i)
    else
      path.push("/location/#{ location }") unless location.blank?
      path.push("/#{ Slug.for(organization.name) }/#{ organization.id }") unless organization.blank?
    end

    query[:keywords] = keywords unless keywords.blank?
    query[:order] = order unless order.blank?
    query[:page] = page unless page.blank?
    query[:per_page] = per_page unless per_page.blank?

    query_string = query.query_string

    url = path.join('/').squeeze('/')
    url += "?#{ query_string }" unless query_string.blank?
    url
  end
  helper_method(:browse_directory_path)

  def browse_events_path(options = {})
    options.to_options!
    context = (defined?(@context) ? @context : {}).to_options!

    query = {}

    location = options[:location] || context[:location] || default_location
    category = options[:category] || context[:category]
    date = options[:date] || context[:date]

    organization = options[:organization] || context[:organization]

    keywords = options[:keywords]
    order = options[:order]
    page = options[:page]
    per_page = options[:per_page]

    location = location.prefix if location.respond_to?(:prefix)
    category = category.name if category.respond_to?(:name)
    organization = organization.id if organization.is_a?(Organization)
    category = category.parameterize('_') if category
    date = Slug.for(date) if date

    path = []
    path.push("/events")

    if(location and options[:location] != false)
      path.push("/location/#{ location }") unless location.blank?
      path.push("/category/#{ category }") unless(category.blank? or category =~ /^All$/i)
      path.push("/date/#{ date }") unless(date.blank? or date =~ /^All$/i)
    else
      path.push("/organization/#{ organization }") unless organization.blank?
    end

    query[:keywords] = keywords unless keywords.blank?
    query[:order] = order unless order.blank?
    query[:page] = page unless page.blank?
    query[:per_page] = per_page unless per_page.blank?

    query_string = query.query_string

    url = path.join('/').squeeze('/')
    url += "?#{ query_string }" unless query_string.blank?
    url
  end
  helper_method(:browse_events_path)

  def default_location
    if session[:location].blank?
      '/colorado'
    else
      session[:location]
    end
  end

=begin
  def ApplicationController.ver()
    git_ver = server_info['git_rev']
    return "v=" + git_ver
  end
  def ver
    ApplicationController.ver
  end
  helper_method :ver
=end

end
