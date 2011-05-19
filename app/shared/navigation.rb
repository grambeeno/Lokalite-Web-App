# factored out mixin for controllers/views
#
  Shared(:navigation) do

  # class to encapsulate a nav
  #
    class Navigation
      attr_accessor :label
      attr_accessor :options
      attr_accessor :html_options
      attr_accessor :pattern
      attr_accessor :active

      def initialize label, *args, &active
        @label = label
        @options = args.shift
        @html_options = args.shift
        @active = active || default_active
        @pattern = Navigation.pattern_for(label)
      end

      def Navigation.pattern_for word
        %r/\b#{ word.to_s.strip.downcase.sub(/\s+/, '_') }\b/i
      end

      def default_active
        lambda do
          current_controller = ApplicationController.current
          fullpath = current_controller.send(:request).fullpath
          # label.downcase.strip == File.basename(fullpath).strip.downcase
          begin
            fullpath == "/" ? true : fullpath =~ pattern
          rescue Object
            false
          end
        end
      end

      def active? &block
        if block
          @active = block
          self
        else
          @active.call ApplicationController.current
        end
      end
      alias_method 'active', 'active?'
      alias_method 'activate', 'active?'
    end

  protected
    def self.nav(*a, &b) Navigation.new(*a, &b) end
    def nav(*a, &b) Navigation.new(*a, &b) end
    helper_method 'nav'
    class ::Object
      def Navigation(*a, &b) ::ApplicationController::Navigation.new(*a, &b) end
    end

  # class level methods for declaring navigation
  #
    def self.navigation *args, &block
      @@navigation ||= {} 
      @@navigation[self] = args unless args.empty?
      @@navigation[self] = block if block

      ancestors.each do |ancestor|
        if @@navigation.has_key?(ancestor)
          value = @@navigation[ancestor]
          return( value.respond_to?(:call) ? value.call : value )
        end
      end

      return nil
    end

    def self.navigation= args
      ( @@navigation ||= {} )[self] = args
    end

    def self.navigation?
      navigation
    end


    def navigation *args, &block
      @navigation = args unless args.empty?
      @navigation = block if block
      @navigation || self.class.navigation
    end
    helper_method(:navigation)

    def navigation?
      navigation
    end
    helper_method(:navigation?)

    def navigation= args
      @navigation = args
    end
    helper_method(:navigation=)

  # methods to display and configure the navigation
  #
    #helper do
      def navigation_for_request
        navigation = navigation_for_current_controller || navigation_for_current_role
        navigation = [ navigation ].flatten.compact
        return '' if navigation.empty?

        unless navigation.empty?
          navigation.first.active?{ true } unless navigation.any?{|nav| nav.active?}
        end

        if respond_to?(:render_navigation)
          render_navigation(navigation)
        else
          default_html_for_navigation(navigation)
        end
      end
      helper_method(:navigation_for_request)

      def default_html_for_navigation(navigation)
        activated = false

        ul_(:class => 'navigation', :id => 'navigation'){
          navigation.each_with_index do |element, index|
            css_id = "navigation-#{ index }"
            css_class = activated ? 'inactive' : ((activated ||= element.active) ? 'active' : 'inactive')
            css_class += ' navigation'
            li_(:id => css_id, :class => css_class){
              link_to(element.label, url_for(element.options), element.html_options||{})
            }
          end
        }
      end
      helper_method(:default_html_for_navigation)
    #end

    def navigation_for_current_controller
      current_controller = ApplicationController.current
      #current_controller.send(:navigation)
      case current_controller
        when EventsController, DirectoryController, TestController
          navigation = [
            nav('Events', events_path, {:title => 'Events'}),
            nav('Directory', directory_path, {:title => 'Directory'})
          ]
        else
          []
      end
    end
    helper_method 'navigation_for_current_controller'

    def navigation_for_current_role
      static_navigation = [
      ]

      navigation = [
        nav('Events', events_path, {:title => 'Events'}),
        nav('Directory', directory_path, {:title => 'Directory'})
      ]

      navigation + static_navigation
    end
    helper_method 'navigation_for_current_role'

    def navigation_for_user
      [
      ]
    end
    helper_method 'navigation_for_user'

    def navigation_for_admin
      [
      ]
    end
    helper_method 'navigation_for_admin'

  end
