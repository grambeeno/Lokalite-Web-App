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

  def advertise_email(email_params)
    @recipients = 'info@lokalite.com'
    @from = 'lokalite@lokalite.com' 
    @company = email_params[:company]
    @subscription = email_params[:subscription]
    @featuring_events = email_params[:featuring_events]
    @social_media = email_params[:social_media]
    @non_profit = email_params[:non_profit]
    @body["email_body"] = email_params[:comments]
    @body["email_name"] = email_params[:name]
    @budget = email_params[:budget]
    @phone = email_params[:phone]
    @start = email_params[:begin]
    @first_name = email_params[:first_name]
    @last_name = email_params[:last_name]
    @city = email_params[:city]
    @agency = email_params[:agency]
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
