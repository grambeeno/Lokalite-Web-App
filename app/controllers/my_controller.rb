class MyController < My::Controller
  def account
    @user = current_user
  end

  def profile
    @user = current_user
    if request.put?
      params[:user].delete(:password) if params[:user][:password].blank?
      if @user.update_attributes(params[:user])
        flash[:success] = 'Your profile has been updated.'
        redirect_to :back
      else
        render :profile
      end
    end
  end

end
