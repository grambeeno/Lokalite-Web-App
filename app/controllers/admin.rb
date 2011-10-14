module Admin
  class Controller < ::ApplicationController
    layout 'application'

    before_filter :authenticate_user!
    before_filter :require_admin

  private
    #alias_method(:admin, :current_user)
    #helper_method(:admin)
  end
end
