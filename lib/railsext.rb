# force rails const_missing to preload these classes
#
    ActionController
    ActionController::Base
    #ActionController::TestCase
    ActiveRecord
    ActiveRecord::Base
    #ActionView
    #ActionView::Base
    #ActionView::Template
    #ActionView::Helpers
    #ActiveSupport::Inflector
    #ActiveSupport::Inflector::Inflections
     
# support for using helper methods in controllers/models/models or anywhere
#
  class Helper < ActionView::Base
    attr_accessor 'options'
    attr_accessor 'args'
    attr_accessor 'block'
    attr_accessor 'controller'
    attr_accessor 'modules'

    def initialize(*args, &block)
      @options = args.extract_options!.to_options!
      @args = args
      @block = block

      controllers, args = args.partition{|arg| ActionController::Base === arg}

      @controller =
        controllers.first ||
        (ActionController.current if ActionController.respond_to?(:current)) ||
        mock_controller

      @modules = args

      @controller = controller
      @modules.push(nil) if @modules.empty?
      @modules.flatten.uniq.each do |mod|
        case mod
          when NilClass, :all, 'all'
            extend ::ActionView::Helpers
          when Module
            extend mod
          else
            raise ArgumentError, mod.class.name
        end
      end
    end

    def session
      controller.session
    end

    ### see ./actionpack/test/controller/caching_test.rb 
    def mock_controller
      #require 'action_controller/test_process' unless defined?(::ActionController::TestRequest)
      require 'action_dispatch/testing/test_request.rb'
      require 'action_dispatch/testing/test_response.rb'
      @store = ActiveSupport::Cache::MemoryStore.new
      @controller = ApplicationController.new
      @controller.perform_caching = true
      @controller.cache_store = @store
      @request = ActionDispatch::TestRequest.new
      @response = ActionDispatch::TestResponse.new
      #@params = {:controller => 'posts', :action => 'index'}
      #@controller.params = @params
      @controller.request = @request
      @controller.response = @response
      @controller.send(:initialize_template_class, @response)
      @controller.send(:assign_shortcuts, @request, @response)
      #@controller.send(:extend, Rails.application.routes.url_helpers)
      @controller.send(:default_url_options).merge!(DefaultUrlOptions) if defined?(DefaultUrlOptions)
      @controller
    end
    def mock_controller
    end

   def _routes
     Rails.application.routes
   end

   def default_url_options
     defined?(DefaultUrlOptions) ? DefaultUrlOptions : {}
   end

   #include ActionController::UrlWriter
   include Rails.application.routes.url_helpers
  end

# state for current controller
#
  module ActionController
    class Base
      class << self
        def current
          @@current if defined?(@@current)
        end
        alias_method 'current_controller', 'current'

        def current= controller
          @@current = controller
        end
      end
    end

    def ActionController.current
      ActionController::Base.current
    end
    def ActionController.current_controller
      ActionController::Base.current
    end

    def ActionController.current= controller
      ActionController::Base.current = controller
    end
  end

# support for using named routes from the console
#
  module Kernel
  private
    def use_named_routes_in_the_console! options = {}
      include ActionController::UrlWriter
      options.to_options!
      options.reverse_merge!(:host => 'localhost', :port => 3000)
      default_url_options.reverse_merge!(options)
    end
  end

# support for top level db transaction/rollback
#
  module Kernel
  private
    def transaction(*args, &block)
      ActiveRecord::Base.transaction(*args, &block)
    end

    def rollback!
      raise ActiveRecord::Rollback
    end
  end

# support for executing sql on the raw connection, getting back an array of
# results
#
  class Object
    def db(*a, &b)
      connection = ActiveRecord::Base.connection.raw_connection
      return connection if a.empty? and b.nil?
      adapter = ActiveRecord::Base.configurations[ Rails.env ][ 'adapter' ].to_s
      case adapter.to_s
        when 'oci', 'oracle'
          cursor = connection.exec *a
          if b
            while row = cursor.fetch;
              b.call row
            end
          else
            returning [] do |rows|
              while row = cursor.fetch
                rows << row
              end
            end
          end

        when 'mysql', 'postgresql', 'sqlite', 'sqlite3'
          if b
            connection.query(*a).each do |row|
              b.call row
            end
          else
            returning [] do |rows|
              connection.query(*a).each do |row|
                rows << row
              end
            end
          end

      else
        raise ArgumentError, "#{ adapter } not implemented yet"
      end
    end
  end

# support for class level declarations of ActiveRecord default values for
# *new* records
#
  class ActiveRecord::Base
    class << self
      def defaults *argv, &block
        const_set(:Defaults, []) unless const_defined?(:Defaults)
        defaults = const_get(:Defaults)

        options =
          if block
            argv.flatten.inject({}){|h,k| h.update k => block}
          else
            case argv.size
              when 2
                { argv.first => argv.last }
              else
                argv.inject({}){|h,x| h.update x.to_hash}
            end
          end
        options.to_options!

        unless options.empty?
          options.each{|k,v| defaults << [k,v]}
          add_after_initialize_with_defaults! defaults
        end

        defaults
      end

      alias_method :default, :defaults

      def add_after_initialize_with_defaults! defaults = {}
        return if defined?(@add_after_initialize_with_defaults)

        after_initialize = instance_method(:after_initialize) rescue nil

        define_method(:after_initialize) do |*args|
          this = self
          after_initialize.bind(self).call(*args) if after_initialize
          return unless new_record?
          defaults.each do |key, value|
            value = instance_eval(&value) if value.respond_to?(:to_proc)
            write_attribute key, value
          end
        end

      ensure
        @add_after_initialize_with_defaults = true unless $!
      end
    end
  end

# support for indexing operator
#
  class ActiveRecord::Base
    def self.[](*args, &block)
      find(*args, &block)
    end
  end

# add simple to_csv method to models
#
  class ActiveRecord::Base
    def self.to_csv(*a, &b)
      require 'csv'

      records =
        if a.empty? and b.nil?
          find(:all, :order => :id)
        else
          find(*a, &b)
        end

      attrs = columns.map(&:name)

      CSV::Writer.generate(string = '') do |csv|
        csv << attrs
        records.each do |record|
          csv << attrs.map{|attr| record.send(attr)}
        end
      end

      string
    end
  end

# support for quoting
#
  class ActiveRecord::Base
    def self.q(*args, &block)
      ActiveRecord::Base.connection.quote(*args, &block)
    end

    def q(*args, &block)
      ActiveRecord::Base.connection.quote(*args, &block)
    end
  end

# support for undecorated models
#
  class ActiveRecord::Base
    class << self
      def base(&block)
        this = self
        if block
          Class.new(ActiveRecord::Base){ set_table_name(this.table_name); module_eval(&block) }
        else
          @base ||= Class.new(ActiveRecord::Base){ set_table_name(this.table_name) }
        end
      end

      public :relation
    end
  end

RailsExt = 42 unless defined?(RailsExt)
