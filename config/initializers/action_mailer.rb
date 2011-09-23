
if Rails.env.production? or ENV['RAILS_EMAIL']
  Rails.configuration.action_mailer.delivery_method = :smtp
  Rails.configuration.action_mailer.perform_deliveries = true
  Rails.configuration.action_mailer.raise_delivery_errors = true

  Rails.configuration.action_mailer.smtp_settings = {
    #:user_name            => 'lokalite@lokalite.com',
    #:password             => 'Lokalblue!',
    :user_name            => 'info@lokalite.com',
    :password             => 'y_E:$dx0!:@H',
    :domain               => 'gmail.com',

    :address              => 'smtp.gmail.com',
    :port                 => 587,
    :authentication       => :plain,
    :enable_starttls_auto => :true
  }

  abort("YOU NEED TO EDIT #{ File.expand_path(__FILE__) }") if
    Rails.configuration.action_mailer.smtp_settings[:password] == 'PASSWORD'
end



### use this for debugging smtp connection errors

if ENV['SMTP_DEBUG']
  class Net::SMTP
    Initialize = instance_method(:initialize)

    def initialize(*args, &block)
      Initialize.bind(self).call(*args, &block)
    ensure
      @debug_output = STDERR
    end
  end
end
