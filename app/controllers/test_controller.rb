class TestController < ApplicationController
  before_filter do |controller|
    controller.instance_eval do
      ### raise unless(local_request? or (current_user and current_user.admin?))
      raise unless local_request?
    end
  end

  Actions = []

  def TestController.method_added(*args, &block)
    super
  ensure
    Actions << args.first.to_s
    Actions.uniq!
  end

  def index
    @actions = Actions.select{|action| TestController.action_methods.include?(action)}
    erb = <<-erb
      <ul>
        <% @actions.each do |action| %>
          <li><%= link_to(action, :action => action)  %></li>
        <% end %>
      </ul>
    erb
    render(:inline => erb, :layout => 'application')
  end


  def show_app_url
    href = App.url
    link = "<a href=#{ href.inspect }>#{ href.inspect }</a>"
    render(:inline => link, :layout => 'application')
  end

  def show_default_url_options
    render(:text => h(DefaultUrlOptions.inspect), :layout => 'application')
  end

  def env
    dump_env(ENV)
  end

  def request_env
    dump_env(request.env)
  end

  def show_current_controller
    show(current_controller)
  end

  def show_session
    show(session)
  end

  def show_params
    show(params)
  end

  def show_helper
    show(Helper.new)
  end

  def demo_x_sendfile
    x_sendfile(__FILE__)
  end

  def show_flash_styles
    flash_message_keys.each do |key|
      flash.now[key.to_sym] = "<a href='.'>#{ key }</a>" + Lorem
    end
    render(:inline => '<em>show_flash_styles</em>', :layout => 'application')
  end

  def show_form_styles
  end

  def session_plus_redirect
    session[:time] = Time.now.utc.iso8601
    redirect_to(:action => :session_plus_redirect_to)
  end

  def session_plus_redirect_to
    show(session)
  end

  def show_api
    show(api)
  end

  def test_tagz
    html = i_{ em_{ '<foo & bar>' } }
    render(:inline => "#{ html } <br /> <%= div_{ :barfoo } %>", :layout => 'application')
  end

  def test_title_helper
    erb = <<-__
      <%= title(:foobar) %>
      42
    __
    render(:inline => erb, :layout => 'application')
  end

  def test_default_content_for
  end

  def test_aside
  end

  def test_conducer
    load 'lib/conducer.rb'

    c = Conducer.for(Venue, self)
    values = []
    values.push c.url_for(:events)
    values.push c.link_to(:events)
    values.push c.sanitize('<script>foo</script>bar')

    render :text => values.inspect, :layout => 'application'
  end

  def test_clean_format
  end

  def double_submit
    html = <<-__
      <br />
      <br />
      <form method=get>
        <input type='submit' onClick='return false'/>
      </form>
    __
    render(:inline => html, :layout => 'application')
  end

private
  Lorem = <<-__
    Ut nulla. Vivamus bibendum, nulla ut congue fringilla, lorem ipsum ultricies
    risus, ut rutrum velit tortor vel purus. In hac habitasse platea dictumst. Duis
    fermentum, metus sed congue gravida, arcu dui ornare urna, ut imperdiet enim
    odio dignissim ipsum. Nulla facilisi. Cras magna ante, bibendum sit amet, porta
    vitae, laoreet ut, justo. Nam tortor sapien, pulvinar nec, malesuada in,
    ultrices in, tortor. Cras ultricies placerat eros. Quisque odio eros, feugiat
    non, iaculis nec, lobortis sed, arcu. Pellentesque sit amet sem et purus
    pretium consectetuer.
  __

  def dump_env(dump_env)
    env = {}
    dump_env.each do |key, val|
      env[key] =
        begin
          val.to_yaml
          val
        rescue
          val.inspect
        end
    end
    render(:text => env.to_a.sort.to_yaml, :content_type => 'text/plain')
  end

  def show(object)
    require 'pp'
    text = PP.pp(object, '')
    render(:text => text, :content_type => 'text/plain')
  end
end
