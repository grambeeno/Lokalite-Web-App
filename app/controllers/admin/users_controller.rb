class Admin::UsersController < Admin::Controller
  skip_before_filter :require_admin, :only => :unsudo

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    order = params[:order] || 'created_at desc'
    options = params.reverse_merge(:per_page => 42, :page => 1)

    @users = User.includes(:roles).paginate(:page => page, :per_page => per_page, :order => order)
  end

  def edit
    @user = User.find(params[:id])
    return if request.get?

    return unless @user == current_user || real_user_is_admin?

    transaction do
      %w( handle email password ).each do |attr|
        value = params[:user][attr]
        @user.send("#{ attr }=", value) unless value.blank?
      end

      return unless @user.save

      if real_user_is_admin?
        %w(admin event_admin).each do |role|
          if params[:user][role] == '1'
            @user.add_role(role)
          else
            @user.remove_role(role)
          end
        end
      end
    end

    message("user #{ @user.email.inspect } updated!", :class => :success)
    redirect_to(:action => :index)
  end

  # We made major changes to the user authentication system so something may not be defined properly. Doesn't allow admin to add user from '/admin/users/new'
  def new
    @user = User.new
    return if request.get?

    params[:user] ||= {}

    User.transaction do
      email = params[:user][:email]
      password = params[:user][:password]

      @user = User.create(:email => email, :password => password)
    end

    message("user #{ @user.email.inspect } created!", :class => :success)
    redirect_to(:action => :index)
  end

  def sudo
    @user = User.find(params[:id])
    session[:effective_user] = @user.uuid
    message("you are logged in as #{ @user.email.inspect }", :class => :info)
    redirect_to('/')
  end

  def unsudo
    session.delete(:effective_user)
    redirect_to(:action => :index)
  end
end

