class APIController < ApplicationController
  layout false

  skip_before_filter true
  skip_before_filter :verify_authenticity_token

  before_filter :setup_path
  before_filter :setup_api

  WhiteList = ['ping',
               'events/browse',
               'events/show',
               'events/recommended'
  ]

  ### skip_before_filter :set_current_user if Rails.env.production?

##
# /api/foo/2/bar/4 -> api.call('/foo/2/bar/4')
#
  def call
    path = params[:path]
    mode = params['mode'] || (request.get? ? 'read' : 'write')

    result = api.mode(mode).call(path, params)

    respond_with(result)
  end

##
#
  def index
    json = json_for(api.index)

    respond_to do |wants|
      wants.json{ render(:json => json) }
      wants.html{ render(:text => json, :content_type => 'text/plain') }
    end
  end

protected

  def respond_with(result)
    json = json_for(result)

    respond_to do |wants|
      wants.json{ render :json => json, :status => result.status.code }
      wants.html{ render :text => json, :status => result.status.code, :content_type => 'text/plain' }
    end
  end

# if you don't have yajl-ruby and yajl/json_gem loaded your json will suck
#
  def json_for(object)
    if Rails.env.production?
      ::JSON.generate(object)
    else
      ::JSON.pretty_generate(object, :max_nesting => 0)
    end
  end

  def setup_path
    @path = params[:path]
  end

  def path
    @path
  end

  def setup_api
    user =  current_user || authenticate_with_http_basic do |email, password|
      User.authenticate(:email => email, :password => password)
    end

    if user
      @api = user.api
      return
    else
      if white_listed?(path)
        @api = Api.new
      else
        render(:nothing => true, :status => :unauthorized)
      end
    end
  end

  def api
    @api
  end

  def self.white_listed?(path)
    @white_listed ||= ( WhiteList.inject(Hash.new){|hash, white_list_path| hash.update(white_list_path.to_s => true)} )
    @white_listed[path.to_s]
  end

  def white_listed?(path)
    self.class.white_listed?(path)
  end

end

ApiController = APIController ### rails is a bitch - shut her up
