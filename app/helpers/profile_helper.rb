module ProfileHelper
  def profile_breadcrumbs
    returning [] do |parts|
      parts << current_user.full_name
      action = params[:action].titleize
      if action == 'Edit'
        action = 'Edit Profile'
      end
      parts << action
    end.join(' &#x25B8; ')
  end
end
