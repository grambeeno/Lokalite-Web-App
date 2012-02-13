module ProfileHelper
  def profile_breadcrumbs
    returning [] do |parts|
      parts << current_user.full_name
      action = params[:action].titleize
      if action == 'Edit' && params[:controller] == 'profile'
        action = 'Edit Profile'
      elsif action == 'New' && params[:controller] == 'plans'
        action = 'Bookmarks'
      end
      parts << action
    end.join(' &#x25B8; ')
  end
end
