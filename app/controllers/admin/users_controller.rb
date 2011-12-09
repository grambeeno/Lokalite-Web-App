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

    params[:user] ||= {}

    transaction do
      %w( handle email password ).each do |attr|
        value = params[:user][attr]
        @user.send("#{ attr }=", value) unless value.blank?
      end

      return unless @user.save

      unless current_user == @user
        if params[:user][:admin] == '1'
          @user.admin!
        else
          @user.roles.delete(Role.admin) if @user.admin?
        end
      end
    end

    message("user #{ @user.email.inspect } updated!", :class => :success)
    redirect_to(:action => :index)
  end

  # def new
  #   @user = User.new
  #   return if request.get?
  #
  #   params[:user] ||= {}
  #
  #   transaction do
  #     email = params[:user][:email]
  #     password = params[:user][:password]
  #
  #     @signup = Signup.signup!(:email => email, :password => password, :deliver => false)
  #     @user = User.create(:email => @signup.email, :password => @signup.password)
  #     @signup.update_attributes!(:user_id => @user.id)
  #     @signup.token.expire!
  #   end
  #
  #   message("user #{ @user.email.inspect } created!", :class => :success)
  #   redirect_to(:action => :index)
  # end

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

