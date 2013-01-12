module ApplicationHelper
  include Tagz.globally


  def title_for_category(category)
    if category = params[:category].to_a
       category = category.map{|c| c.titleize }
       category.join(', ')
    else
    category = category.upcase if category.upcase == 'MMJ'
    category = category.gsub(/ And /, ' and ')
    category = category + " Events"
  end
  end

  def tile_main_content?
    params[:controller] == 'events' and params[:action] == 'browse'
  end

  def browse_context_for(options = {})
    options.to_options!
    browse_context = OpenStruct.new
    browse_context.category = options[:category] ? options[:category] : ''
    browse_context.date = options[:date] ? options[:date] : ''
    browse_context.location = options[:location] ? File.basename(options[:location]) : ''
    browse_context.keywords = options[:keywords] ? 'matching "' + options[:keywords].ellipsis(25) + '"' : ''
    browse_context
  end

  def display_flash(kind, message_or_options_with_block = {}, options = {}, &block)
    if block_given?
      message = capture(&block)
      options = message_or_options_with_block
    else
      message = message_or_options_with_block
    end

    options.reverse_merge!({
      :close_link => true
    })

    parts = []
    parts << link_to('×', '#dismiss', :class => 'dismiss') if options[:close_link]
    parts << content_tag(:p, message)

    content_tag :div, raw(parts.join), :class => "flash #{kind}"
  end


  def search_form(options = {})
    options.to_options!
    options[:action] ||= fullpath.split(/[?]/).first
    options[:name] ||= 'keywords'
    options[:method] ||= 'get'
    #options[:class] ||= 'center-search'
    options[:class] ||= 'sidebar-search'

    #placeholder = options[:keywords] || params[:keywords] || 'LIFE OUTSIDE THE BOX'
    #placeholder = 'SEARCH'
    placeholder = ''

    if options[:context]
      context(options[:context])
    else
      if params[:keywords]
        #context("#{ context_for_fullpath } [ &ldquo;#{ h params[:keywords] }&rdquo; ]")
      end
    end

    form_(:class => options[:class], :method => options[:method], :action => options[:action]){
      div_{
        input_(:type => 'search', :name => 'keywords', :id => 'keywords', :title => placeholder, :placeholder => placeholder){}
      }
    }
  end

  def css_for(options = {})
    options.to_css
  end

  def context_for_request(*args)
    sep = ' | '
    if args.empty?
      default_content_for(:context){ context_for_fullpath }
    else
      content_for(:context){ args.join(sep) }
      content_for(:context)
    end
  end
  alias_method('context', 'context_for_request')

  def context_for_fullpath
    sep = ' | '
    fullpath[1..-1].split(%r|[?]|).first.split(%r|/|).map{|word| Slug.for(word)}.join(sep)
  end

  def title
    if boulder_weekly?
      parts = []
      parts << "Boulder County Events"
    else
      parts = []
      parts << @event.name if @event
      parts << @organization.name if @organization
      parts << 'Promote your business' if current_page?(business_promo_path) || current_page?(business_sign_up_path)
      parts << "lokalite"
      parts << 'For Local Events' if current_page?('/landing')
      parts << 'For Local Events' if current_page?('/')
      parts << title_for_category(params[:category]) if params[:category]
      parts.join(' | ')
    end
  end

   def bw_title
     parts = []
     parts << "Boulder Weekly Events"
     parts << title_for_category(params[:category]) if params[:category]
     parts.join(' | ')
   end
 
 def default_content_for(name, &block)
    if !content_for?(name)
      content_for("default_#{ name }", &block)
      content_for("default_#{ name }")
    else
      content_for(name)
    end
  end

  def content_for_style(&block)
    default_content_for(:style, &block)
  end

  def content_for_script(&block)
    default_content_for(:script, &block)
  end

  def jsonp(*args, &block)
    name = args.shift || 'jsonp'
    callback = params[:callback] || params[:cb]

    content = capture(&block)

    unless callback
      concat(content)
    else
      concat("#{ callback }(#{ content.to_json })")
    end
  end

# generic form helps handling AR objects and other shiznit
#
  def form(*args, &block)
    options = args.extract_options!.to_options!

    if args.first.is_a?(ActiveRecord::Base)
      model = args.first

      url = options.delete(:url) || request.fullpath

      html = form_attrs(options)

      options.clear

      options[:url] = url
      options[:html] = html.dup

      form_for(model, options, &block)
    else
      args.push(request.fullpath) if args.empty?
      args.push(form_attrs(options))
      form_tag(*args, &block)
    end
  end

  alias_method 'form_on', 'form'


# merge default with specified form options.  recognizes some special form
# classes like 'small' 'medium', etc...
#
  def form_attrs(*args)
    args.flatten!
    options = args.extract_options!.to_options!.dup
    options[:class] ||= []
    options[:class] = Array(options[:class])
    options[:class].push('app')
    options[:class].push(args.map{|arg| arg.to_s})
    options[:class].flatten!
    options[:class].compact!
    options[:class].uniq!
    options[:class] = options[:class].join(' ')
    options[:enctype] ||= "multipart/form-data"
    options
  end


# hash in -> css style definition out
#
  def css_for(hash)
    unless hash.blank?
      css = []

      hash.each do |selector, attributes|
        unless attributes.blank?
          guts = []
          attributes.each do |key, val|
            guts << "#{ key } : #{ val };"
          end
          unless guts.blank?
            css << "#{ selector } { #{ guts.join(' ') } }"
          end
        end
      end

      unless css.empty?
        css.join("\n")
      end
    end
  end

# hacked version of the activesupport mail_to method, this one supports bcc
#
  def mail_to(email, *args)
    options = args.extract_options!.to_options!

    name = args.shift || email.to_s
    html_options = (options.delete(:html) || {}).to_options!

    extras = ''
    options.each do |key, val|
      extras << "#{key}=#{CGI.escape(val).gsub("+", "%20")}&" unless val.blank?
    end
    extras = "?" << extras.gsub!(/&?$/,"") unless extras.empty?

    email_address = email.to_s
    email_address_obfuscated = email_address.dup
    email_address_obfuscated.gsub!(/@/, html_options.delete("replace_at")) if html_options.has_key?("replace_at")
    email_address_obfuscated.gsub!(/\./, html_options.delete("replace_dot")) if html_options.has_key?("replace_dot")

    string = ''
    encode = html_options.delete("encode").to_s
    if encode == "javascript"
      "document.write('#{content_tag("a", name || email_address_obfuscated, html_options.merge({ "href" => "mailto:"+email_address+extras }))}');".each_byte do |c|
        string << sprintf("%%%x", c)
      end
      "<script type=\"#{Mime::JS}\">eval(unescape('#{string}'))</script>"
    elsif encode == "hex"
      email_address_encoded = ''
      email_address_obfuscated.each_byte do |c|
        email_address_encoded << sprintf("&#%d;", c)
      end

      protocol = 'mailto:'
      protocol.each_byte { |c| string << sprintf("&#%d;", c) }

      email_address.each_byte do |c|
        char = c.chr
        string << (char =~ /\w/ ? sprintf("%%%x", c) : char)
      end
      content_tag "a", name || email_address_encoded, html_options.merge({ "href" => "#{string}#{extras}" })
    else
      content_tag "a", name || email_address_obfuscated, html_options.merge({ "href" => "mailto:#{email_address}#{extras}" })
    end
  end
  alias_method('mailto', 'mail_to')

# keeps paragraphs and linebreaks
#
  # def simple_format(string, options = {})
  #   content = string.to_s.strip
  #   return content unless(content =~ %r/\\n/)
  #   content.gsub!(/\\r\\n?/, "\\n")                     # \\r\\n and \\r -> \\n
  #   content.gsub!(/\\n\\n+/, "</p>\\n\\n<p>")            # 2+ newline  -> paragraph
  #   content.gsub!(/([^\\n]\\n)(?=[^\\n])/, '\\1<br />')  # 1 newline   -> br
  #   raw("<p>#{ content }</p>")
  # end

  # keeps paragraphs, linebreaks.  sanitizes js/html.  and hyperlinks linky looking stuff
  #
  def clean_format(string, options = {})
    options.to_options!
    target = options[:target] || '_blank'
    content = sanitize(string.to_s)
    content = auto_link(content, :all, :target => target)
    content = simple_format(content, options)
  end

# unicode chars
#
  def left_quote()
    '&#8220;'
  end
  def right_quote()
    '&#8221;'
  end
  def small_right_pointing_triangle
    '&#x25B8;'
  end
  def right_pointing_triangle
    '&#x25B6;'
  end
  def space
    '&nbsp;'
  end

# dump javascript wrapped in jQuery onload wrapper into the page
#
  def jQuery(*javascript, &block)
    block.call(javascript) if block
    "
      jQuery(function(){
        #{ raw(javascript.flatten.compact.join("\n")) }
      });
    "
  end

# helper for rendering another action/view with params inside a view
#
  def render_to_string(*args, &block)
    controller.send(:render_to_string, *args, &block)
  end


# hms(61) #=> 00:01:01
#
  def hms(seconds)
    Util.hms(seconds)
  end

# unwrap("<div> <span> foobar </span> </div>", :tags => %w( div span)) #=> "foobar"
#
  def unwrap(content, options = {})
    unwrap!("#{ content }", options)
  end

  def unwrap!(content, options = {})
    content = content.to_s
    options.to_options!
    tags = [options[:tag], options[:tags]].flatten.compact
    tags.each do |tag|
      content.sub!(%r|^\s*<#{ tag }[^>]+>|, '')
      content.sub!(%r|</#{ tag }>\s*$|, '')
    end
    content
  end

# a unique domid
#
  def domid
    App.domid
  end

# simple error message generator
#
  def errors_for(*errors)
    if errors.size==1 and errors.first.respond_to?(:errors)
      errors_on(errors.first)
    else
      raw('<div class="errors">' + errors.flatten.compact.uniq.join('<br />') + '</div>')
    end
  end

  def errors_on(object, options = {})
    options.to_options!

    at_least_one_error = false
    css_class = options[:class] || 'dao errors'
    separator = options[:separator] || '⇒'

    to_html =
      table_(:class => css_class){
        caption_{ "We're so sorry, but can you please fix the following errors?" }
        object.errors.each do |key, message|
          at_least_one_error = true
          key = '*' if key==:base
          tr_{
            #if key == :base
              #td_(:class => :message, :colspan => 3){ message }
            #else
              td_(:class => :key){ key }
              td_(:class => :separator){ separator }
              td_(:class => :message){ message }
            #end
          }
        end
      }
    at_least_one_error ? to_html : ''
  end

  # possessive("United States") => "United States'"
  # possessive("Colorado") => "Colorado's"
  def possessive(noun)
    (noun.pluralize == noun) ? "#{noun}'" : "#{noun}'s"
  end

  def current_location_name_robust
    if params[:location]
      current_location_name
    elsif @event
      @event.location.locality
    else
      # copied from EventsController
      default_location = Location.absolute_path_for(
        session[:location].blank? ? Location.default : session[:location]
      )
      (default_location.split('/').last || '').titleize
    end
  end
end
