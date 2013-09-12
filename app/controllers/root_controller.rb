class RootController < ApplicationController

  def index
    if session[:skip_landing_page]
      redirect_to events_path(:origin => params[:origin], :category => 'featured')
    elsif boulder_weekly?
      session[:skip_landing_page] = true
    else
      render :action => :landing
    end
    session[:skip_landing_page] = true
  end

  # def set_location
  #   flash[:return_to] ||= http_referrer
  #   flash.keep
  #
  #   @prefixes = Location.list
  #
  #   prefix = params[:location]||params[:prefix]
  #
  #   return if prefix.blank?
  #   raise unless Location.prefix?(prefix)
  #
  #   return_to = flash[:return_to]
  #   return_to = '/' if return_to.blank?
  #   flash[:location] = prefix
  #   redirect_to(return_to == fullpath ? '/' : return_to)
  # end
end
