module My
  class Controller < ::ApplicationController
    before_filter :authenticate_user!

  private
    alias_method(:my, :current_user)
    helper_method(:my)
  end
end
