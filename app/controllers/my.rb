module My
  class Controller < ::ApplicationController
    before_filter :require_current_user

  private
    alias_method(:my, :current_user)
    helper_method(:my)
  end
end
