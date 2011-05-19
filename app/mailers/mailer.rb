class Mailer < ActionMailer::Base
  default_url_options.merge(
    DefaultUrlOptions
  )

  default(
    :from => App.email
  )

  def signup(*args)
    options = args.extract_options!.to_options!
    @signup = args.shift || options.fetch(:signup)
    @token = @signup.token
    @email = @signup.email
    @activation_url = activate_path(:token => @token.to_s, :only_path => false)
    @subject = subject_for("Please activate your account.")
    mail(:to => @email, :subject => @subject)
  end

  def password(*args)
    options = args.extract_options!.to_options!
    @user = args.shift || options.fetch(:user)
    @token = args.shift || options[:token] || @user.password_token
    @email = @user.email
    @password_url = password_path(:token => @token.to_s, :only_path => false)
    @subject = subject_for("Please reset your password.")
    mail(:to => @email, :subject => @subject)
  end

  def invitation(*args)
    options = args.extract_options!.to_options!
    @user = args.shift || options.fetch(:user)
    @token = args.shift || options[:token] || @user.password_token
    @email = @user.email
    @password_url = password_path(:token => @token.to_s, :only_path => false)
    @subject = subject_for("Please accept the following invitation.")
    mail(:to => @email, :subject => @subject)
  end

  def test(email)
    mail(:to => email, :subject => 'test')
  end

protected
  def subject_for(*args)
    ["[#{ App.domain }]", *args.compact.flatten].join(' ')
  end

  def signature
    "-- Thanks from the #{ App.domain } team."
  end
  helper_method :signature 
end
