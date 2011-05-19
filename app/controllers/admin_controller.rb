class AdminController < Admin::Controller
  def index
    redirect_to('/admin/users')
  end
end
