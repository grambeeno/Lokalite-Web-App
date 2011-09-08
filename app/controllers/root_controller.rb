class RootController < ApplicationController

  def index
    # redirect_to events_path(:origin => params[:origin], :category => 'featured')
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
