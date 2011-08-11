# standard ENV settings should be places in env.yml or env.rb, this can be
# used to force the app into a particular mode
#
#
  config_dir = File.dirname(__FILE__)
  env_yml = File.join(config_dir, 'env.yml')
  env_rb = File.join(config_dir, 'env.rb')
  ENV.update(YAML.load(IO.read(env_yml))) if test(?e, env_yml)
  Kernel.load(env_rb) if test(?e, env_rb)

# handle compound RAILS_ENV:RAILS_STAGE settings (ie. production_staging or production:staging).
#
  parts = (ENV['RAILS_ENV'] || 'development').to_s.split(%r/[._:-]+/)
  if parts.size > 1
    rails_env = parts.shift
    rails_stage = parts.shift
    ENV['RAILS_ENV'] = rails_env
    ENV['RAILS_STAGE'] ||= rails_stage
    abort('conflicting RAILS_STAGE setting') unless ENV['RAILS_STAGE'] == rails_stage
  end

# the normal rails preamble
#
  require File.expand_path('../boot', __FILE__)
  require 'rails/all'

# finish setting up RAILS_STAGE here
#
  RAILS_STAGE = ActiveSupport::StringInquirer.new(ENV['RAILS_STAGE'] ||= Rails.env)
  def Rails.stage() RAILS_STAGE end

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
#
  Bundler.require(:default, Rails.env) if defined?(Bundler)

# support pre-initializers...
#
  config_dir = File.dirname(File.expand_path(__FILE__))
  glob = File.join(config_dir, 'preinitializers', '**/**.rb')
  preinitializers = Dir.glob(glob)
  preinitializers.each{|preinitializer| Kernel.load(preinitializer)}

# finally, the application initializer
#
  module Lokalite
    class Application < Rails::Application
  
        config.after_initialize do
          require 'app/api.rb'
          require 'yajl/json_gem'
        end

        config.autoload_paths += %w( lib app )


      # Settings in config/environments/* take precedence over those specified here.
      # Application configuration should go into files in config/initializers
      # -- all .rb files in that directory are automatically loaded.

      # Custom directories with classes and modules you want to be autoloadable.
      # config.autoload_paths += %W(#{config.root}/extras)
        #config.autoload_paths += %W( #{ config.root }/app #{ config.root }/app/app/ )

      # Only load the plugins named here, in the order given (default is alphabetical).
      # :all can be used as a placeholder for all plugins not explicitly named.
      # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

      # Activate observers that should always be running.
      # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

      # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
      # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
      # config.time_zone = 'Central Time (US & Canada)'

      # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
      # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
      # config.i18n.default_locale = :de

      # JavaScript files you want as :defaults (application.js is always included).
      # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)
      #
      #config.action_view.javascript_expansions[:defaults] = %w( jquery rails )
       

      # Configure the default encoding used in templates for Ruby 1.9.
      config.encoding = "utf-8"

      # Configure sensitive parameters which will be filtered from the log file.
      config.filter_parameters += [:password, :passphrase]

    # local libs/gems that can/must be loaded *before* rails initializer
    #
      require 'open-uri' unless defined?(OpenURI)
      require 'openssl' unless defined?(OpenSSL)
      require 'rubyext' unless defined?(RubyExt)
      require 'slug' unless defined?(Slug)
      require 'logging' unless defined?(Logging)
      require 'lockfile' unless defined?(Lockfile)
      require 'map' unless defined?(Map)
      require 'fattr' unless defined?(Fattr)
      # require 'ggeocode' unless defined?(GGeocode)
      require 'earth_tools' unless defined?(EarthTools)
      require 'ostruct' unless defined?(OpenStruct)

   
    # local libs/gems that can/must be loaded *inside* rails initializer
    #
      require 'uuidtools' unless defined?(UUID)
      require 'util' unless defined?(Util)
      require 'encoder' unless defined?(Encoder)
      require 'encryptor' unless defined?(Encryptor)
      require 'shared' unless defined?(Shared)
      require 'bcrypt' unless defined?(BCrypt)

    # local libs/gems that can/must be loaded *after* rails initializer
    #
      config.autoload_paths += Dir.glob("vendor/gems/dao-*/lib") 
      config.after_initialize do
        require 'railsext' unless defined?(RailsExt)
        require 'tagz' unless defined?(Tagz)
        require 'yajl/json_gem' unless defined?(Yajl)
        require 'raptcha' unless defined?(Raptcha)
        require 'dao' unless defined?(Dao)
        require 'carrierwave' unless defined?(CarrierWave)
        require 'mini_magick' unless defined?(MiniMagick)
        require 'image_cache' unless defined?(ImageCache)
        require 'pg_search' unless defined?(Texticle)
        # require 'pg_search' unless defined?(Texticle)
        require 'will_paginate' unless defined?(WillPaginate)
      end

    # do the actual logging configuration - this one will keep 7 log files of
    # roughly 42 mega-bytes on disk and fill not your lovely drive - unless you
    # are in IRB, in which case the logger is not touched...
    #
    # it *seems* like this should be in an initializer but, alas, rails does
    # some weird things with dup'ing loggers that makes it safer to do right
    # *here*
    #
      unless STDIN.tty? or defined?(Rails::Console)
        require 'fileutils'
        FileUtils.mkdir_p(File.join(Rails.root, 'log'))

        logpath       = config.paths.log.first.to_s
        number_rolled = 7
        megabytes     = 2 ** 20
        max_size      = 42 * megabytes
        options       = { :safe => true } # for multi-process safe rolling

        logger = ::Logging.logger(logpath, number_rolled, max_size, options)

        config.logger = logger
        config.logger.level = Rails.env.production? ? :info : :debug
      end
    end
  end

# load our app singleton extentions dead last
#
  require 'app'
