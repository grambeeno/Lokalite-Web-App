class SitemapController < ApplicationController

  cache_page :index, :boulder_events, :boulder_places

  def index
    @sitemaps = "http://lokalite.dev:3000/sitemap/boulder_events.xml", "http://lokalite.dev:3000/sitemap/boulder_places.xml" 

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
    Time.now.to_s
  end

  def expire_cache
    expire_action :action => :index
    render :text => 'Cache Expired'
  end

end
