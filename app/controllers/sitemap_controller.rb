class SitemapController < ApplicationController

  def index
    @urls = [ url_for :controller => 'root', :action => 'landing' ], [ url_for :controller => 'events' ], [ url_for :controller => 'places' ], [ url_for :controller => 'static', :action => 'about' ], [ url_for :controller => 'static', :action => 'contact' ], [ url_for :controller => 'static', :action => 'terms' ], [ url_for :controller => 'static', :action => 'privacy_policy' ], [ url_for :controller => 'static', :action => 'press_coverage' ], [ url_for :controller => 'static', :action => 'sitemap' ]    

    headers['Content-Type'] = 'application/xml'
    render :layout => false
  end
end


