module FacebookHelper
  def facebook_comments(options)
    options.reverse_merge!({
      :posts => 3,
      :width => 710
    })
    raw "<fb:comments href='#{options[:url]}' num_posts='#{options[:posts]}' width='#{options[:width]}'></fb:comments>"
  end

  # The js api for this seems to be broken for everyone. Use a plain link instead.
  # See properties here:
  # http://developers.facebook.com/docs/reference/dialogs/send/
  def send_facebook_message_url(options)
    options.reverse_merge!({
      :app_id => FACEBOOK_APP_ID,
      :redirect_uri => 'http://lokalite.com' || 'events.boulderweekly.com'
    })
    "https://www.facebook.com/dialog/send?#{hash_to_url_params(options)}"
  end

  def hash_to_url_params(hash)
    hash.map{|key, value| "#{key}=#{value}" }.join('&')
  end
end
