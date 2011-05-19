module Admin
  class Controller < ::ApplicationController
    layout 'application'

    before_filter :require_current_user
    before_filter :require_admin_user

  private
    #alias_method(:admin, :current_user)
    #helper_method(:admin)
  end
end
