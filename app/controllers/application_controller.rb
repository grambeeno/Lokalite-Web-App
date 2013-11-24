class ApplicationController < ActionController::Base
  include Tagz.globally

  protect_from_forgery

  layout :layout_for_request

  before_filter :configure_default_url_options!
  before_filter :set_user_time_zone
  before_filter :set_origin
  before_filter :set_effective_user, :handle_business_sign_up, :handle_invitations
  before_filter :prepare_for_mobile
  before_filter :set_fb

  # before_filter :show_holding_page

protected

  def set_effective_user
    return unless user_signed_in? && current_user.admin?
    if session.key?('effective_user')
      @real_user    = current_user
      @current_user = User.find_by_uuid(session['effective_user'])
    end
  end
  def mobile_device?
    if session[:mobile_param]
       session[:mobile_param] == '1'     
    else
       request.user_agent =~ /Mobile|webOS|AvantGo|Dolphin|OpenWave|Plucker|NetFront|PIE|AT&T|RiM|9xxx Series|88xx Series|Cricket|Dell|Googlebot-Mobile|HP|HTC|LGE|Motorola/
    end
end

  helper_method :mobile_device? 

  def prepare_for_mobile
    session[:mobile_param] = params[:mobile] if params[:mobile]
    if mobile_device?
      request.format = :mobile  
    end
#    if mobile_device? && request.subdomain != 'm'
#      redirect_to 'http://m.lokalite.com'
#    end
  end

  def fb?
    if session[:fbview_param]
       session[:fbview_param] == '1'
    end
  end

    helper_method :fb?

  def set_fb
    session[:fbview_param] = params[:fbview] if params[:fbview]
    request.format = :fbview if fb?
  end

  # def show_holding_page
  #   unless logged_in? || %w[auth api].include?(params[:controller]) || params[:action] == 'business' || Rails.env == 'development'
  #     render :file => 'public/holding-page.html', :layout => false
  #   end
  # end

  def set_origin
    origin = session[:origin] || 'boulder-colorado'
    params[:origin] = origin if params[:origin].blank?
  end

  def permission_denied
    flash[:notice] = "Sorry, you don't have access to that page."
    redirect_to root_path and return
  end

  def set_user_time_zone
    Time.zone = current_user.time_zone if user_signed_in?
    Chronic.time_class = Time.zone
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

  def handle_business_sign_up
    # store in the session when a user is on the business signup page
    if params[:controller] == 'devise/registrations' and params[:business]
      session[:create_organization] = true
    end

    # after an acount is created, redirect them to create their organization
    if user_signed_in? and session.delete(:create_organization)
      redirect_to new_my_organization_path and return
    end
  end

  def handle_invitations
    if user_signed_in?
      if session.key?('plan_invitation_uuid')
        redirect_to plan_invitation_path(session.delete(:plan_invitation_uuid))
      elsif session.key?('event_invitation_id')
        redirect_to event_invitation_path(session.delete(:event_invitation_id))
      end
    end
  end

# current user support
#
  # def effective_user
  #   @effective_user ||= User.where(:uuid => session[:effective_user]).first
  # end
  # helper_method(:effective_user)

  # def real_user
  #   @real_user ||= User.where(:uuid => session[:real_user]).first
  # end
  # helper_method(:real_user)

  # def current_user
  #   effective_user
  # end
  # helper_method(:current_user)

  def real_user
    if user_sudoing?
      @real_user
    else
      current_user
    end
  end

  def user_sudoing?
    defined?(@real_user)
  end
  helper_method(:user_sudoing?)

  def real_user_is_admin?
    user_sudoing? || current_user.admin?
  end
  helper_method(:real_user_is_admin?)

  def require_admin
    require_role('admin')
  end

  def require_event_admin
    require_role('event_admin')
  end

  def require_role(role)
    unless current_user.has_role?(role)
      message("Sorry, you must have the role *#{role}* in order to view #{ h(request.fullpath) }", :class => :error)
      redirect_to(root_path)
      return
    end
  end

# location support
#
  # def current_location
  #   Location.where('prefix=?', current_location_prefix).first
  # end
  # helper_method :current_location

  # def current_location_prefix
  #   #session[:location] = Location.default.prefix if session[:location].blank?
  #   #session[:location]
  #   @current_location_prefix ||= Location.absolute_path_for(params[:location])
  # end
  # helper_method :current_location_prefix

  # def current_location_name
  #   parts = current_location_prefix.split('/')
  #   last = parts.last
  #   last.titleize if last
  # end
  # helper_method :current_location_name

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

  def after_sign_in_path_for(resource_or_scope)
    root_path
  end
  def ver
    ApplicationController.ver
  end

  helper_method :ver

end
