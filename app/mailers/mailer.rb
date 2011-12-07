class Mailer < ActionMailer::Base
  default_url_options.merge(
    DefaultUrlOptions
  )

  default(
    :from => App.email
  )

  def new_event_notification(event)
    @event   = event
    @subject = subject_for("New event!")
    mail(:to => 'content@lokalite.com', :subject => @subject)
  end

  def test(email)
    mail(:to => email, :subject => 'test')
  end

  def contact_email(email_params)
    @recipients = 'info@lokalite.com'
    @from = email_params[:name]
    @subject = email_params[:subject] 
    @body["email_body"] = email_params[:comments]
    @body["email_name"] = email_params[:name]
    content_type "text/html"
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
