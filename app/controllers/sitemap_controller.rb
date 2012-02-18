class SitemapController < ApplicationController

  caches_page :index

  def index
    @sitemaps = "http://lokalite.com/sitemap/boulder_events.xml", "http://lokalite.com/sitemap/boulder_places.xml" 

    headers['Content-Type'] = 'application/xml'
    render :layout => false
  end

  def boulder_events
    @event_urls = []
    events = Event.browse(:origin => 'boulder-colorado', :per_page => '50000')
    for event in events
    event_url(event.slug, event.id)
    @event_urls << event_url(event.slug, event.id)
    end

    headers['Content-Type'] = 'application/xml'
    render :layout => false
  end

  def boulder_places
    @place_urls = []
    places = Organization.browse(:origin => 'boulder-colorado', :per_page => '50000')
    for @organization in places
    organization_url(@organization.slug, @organization.id)
    @place_urls << organization_url(@organization.slug, @organization.id)
    end

    headers['Content-Type'] = 'application/xml'
    render :layout => false
  end

  def expire_cache
    expire_page :controller => 'sitemap', :action => :index
    render :text => 'Cache Expired'
    render :layout => false
  end

end
