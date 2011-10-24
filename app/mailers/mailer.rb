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

protected
  def subject_for(*args)
    ["[#{ App.domain }]", *args.compact.flatten].join(' ')
  end

  def signature
    "-- Thanks from the #{ App.domain } team."
  end
  helper_method :signature
end
