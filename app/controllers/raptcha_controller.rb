class RaptchaController < ApplicationController
# this is the image responder - it is the *only* action you need here
# 
# you may need a to route /raptcha to this action in config/routes.rb
# 
#
  def index
    Raptcha.render(controller=self, params)
  end

# sample on how to use - you may delete this action
#
  def form
    render :inline => <<-html
      <html>
        <body>
          <hr>
          <em>valid</em>:#{ Raptcha.valid?(params) ? :true : :false }
          <hr>
          <%= form_tag do %>
            #{ Raptcha.input }
            <hr>
            <input type=submit name=submit value=submit />
            <hr>
            <a href="#{ request.fullpath }">new</a>
          <% end %>
        </body>
      </html>
    html
  end

# sample inline image (IE incompatible) - you may delete this action
#
  def inline
    render :inline => <<-html
      <html>
        <body>
          <hr>
          <em>valid</em>:#{ Raptcha.valid?(params) ? :true : :false }
          <hr>
          <%= form_tag do %>
            #{ Raptcha.input :inline => true }
            <hr>
            <input type=submit name=submit value=submit />
            <hr>
            <a href="#{ request.request_uri }">new</a>
          <% end %>
        </body>
      </html>
    html
  end
end

load 'lib/raptcha.rb' if Rails.env.development?
