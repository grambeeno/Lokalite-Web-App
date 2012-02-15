class RobotsController < ApplicationController

  def robots
    if request.subdomain == 'm'
      file = 'public/robots.mobile.txt'
      else
      file = 'public/robots.full.txt'
    end
    robots = File.read(File.join(RAILS.root, file))
    respond_to do |format|
      format.txt {render :text => robots, :layout => false}
    end
  end

end
