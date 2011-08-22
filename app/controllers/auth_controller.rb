class AuthController < ApplicationController
  def signup
    redirect_to events_path and return if logged_in?
    if params[:token]
      redirect_to(url_for(:action => :activate, :token => params[:token]))
      return
    end

    @errors = []
    flash.keep(:return_to)
    return_to = flash[:return_to] || login_path

    @email = email = params[:email]
    @email_confirmation = email_confirmation = params[:email_confirmation]
    @password = password = params[:password]

    return if request.get?

    unless @email and @email.split(/@/).size == 2
      @errors.push "Hrm, that doesn't look like a valid email."
    end

    unless @email === @email_confirmation
      @errors.push "Email and Email Confirmation must be identical."
    end

    unless @password and @password.size >= 3
      @errors.push "Wow, that is a really short password!"
    end

    begin
      signup = Signup.signup!(:email => email, :password => password, :deliver => false)

      if signup.activated?
        message(
          "You've already activated an account for #{ h(signup.email.inspect) }.  Please log in instead.",
          :class => :success
        )
        redirect_to(login_path)
        return
      end

      begin
        signup.deliver!
      rescue
        message(
          "Sending email to #{ h(signup.email.inspect) } failed. Try again later!",
          :class => :error
        )
        redirect_to('/')
        return
      end
    rescue
      raise unless Rails.env.production?
      @errors.push "Eeeks! Something went wrong on our end!? Please try again later."
    end

    return unless @errors.empty?

    message(
      "Great! Next, check your #{ h(signup.email.inspect) } account for an activation message.",
      :class => :success
    )
    link_hint!(activate_path(:token => signup.token.to_s, :only_path => false))

    redirect_to(return_to)
  end

  def activate
    @signup = Signup.for_token(params[:token])

    unless @signup
      message("Eeeks! Something went wrong on our end!? Please try again later.", :class => :error)
      redirect_to('/')
      return
    end

    if @signup.user_id
      message("Sorry, that account has already been activated! Please log in instead.", :class => :error)
      redirect_to(login_path)
      return
    end

    @user = User.create(:email => @signup.email, :password => @signup.password)
    @signup.update_attributes!(:user_id => @user.id)
    @signup.token.expire!

    login!(@user)
    message("Thanks #{ h(@user.email.inspect) } &mdash; Your account has been activated and you are logged in!", :class => :success)
    redirect_to(my_organizations_path)
  end

  def login
    @errors = []
    flash.keep(:return_to)
    return_to = flash[:return_to] || my_organizations_path

    @email = email = params[:email]
    @password = password = params[:password]

    return if request.get?

    @user = User.authenticate(:email => @email, :password => @password)

    case @user
      when nil
        @errors.push "Sorry, incorrect email."
      when false
        @errors.push "Sorry, wrong password!"
    end

    return unless @errors.empty?

    login!(@user)
    redirect_to(return_to)
  end

  def logout
    session.clear
    message("You have been logged out.", :class => :success)
    redirect_to('/')
  end

  def password
    @errors = []
    flash.keep(:return_to)
    return_to = flash[:return_to] || '/'

    @email = email = params[:email]
    @password = password = params[:password]
    @token = token = params[:token]
    @user = nil

    if @token
      @token = Token.where(:uuid => token).first
      @user = @token.user if @token
      @email = @user.email if @user
      unless(@token and @user and not @token.expired?)
        message("Sorry, bad or expired token.", :class => :error)
        redirect_to('/')
        return
      end
    end

    return if request.get?

    if params[:commit] =~ /send/i
      @user = User.where(:email => @email).first
      @token = @user.password_token if @user

      if @user and @token
        @user.deliver_password_email(:token => @token)
        message("An email with instructions has been sent to #{ h(@email) }.", :class => :success)
        link_hint!(password_path(:token => @token.to_s, :only_path => false))
      else
        message("Eeeks, something went wrong.  Please try again later.  Wrong email address #{ h @email.inspect }?", :class => :error)
      end
    end

    if params[:commit] =~ /reset/i
      password  = params[:password]
      unless password.size >= 3
        @errors.push "That password is *way* too short!"
      else
        @user.password = password
        @user.save!
        @token.expire!
        login!(@user)
        message("Your password has been reset and you are logged in.", :class => :success)
        redirect_to('/')
        return
      end
    end

    return unless @errors.empty?

    redirect_to(return_to)
  end

protected
  def login!(user)
    raise user.inspect unless user.uuid
    session.clear
    session[:real_user] = user.uuid
    session[:effective_user] = user.uuid
    session[:admin] = User[user.uuid].admin?
  end

  def link_hint!(*args)
    unless Rails.env.production?
      href = url_for(*args)
      link = "<a href=#{ href.inspect }>#{ h(href) }</a>"
      message(link)
    end
  end
end
