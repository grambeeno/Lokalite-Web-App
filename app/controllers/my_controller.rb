class MyController < My::Controller
  def account
    @user = current_user
  end

  def profile
    @user = current_user
    return if request.get?
  end
end
