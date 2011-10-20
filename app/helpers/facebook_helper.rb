module FacebookHelper
  def facebook_comments(options)
    options.reverse_merge!({
      :posts => 3,
      :width => 710
    })
    raw "<div class='fb-comments' data-href='#{options[:url]}' data-num-posts='#{options[:posts]}' data-width='#{options[:width]}'></div>"
  end


  def send_facebook_message_url(options)
    options.reverse_merge!({
      :app_id => FACEBOOK_APP_ID,
      :redirect_uri => 'http://lokalite.dev'
    })
    "https://www.facebook.com/dialog/send?#{hash_to_url_params(options)}"
  end

  def hash_to_url_params(hash)
    hash.map{|key, value| "#{key}=#{value}" }.join('&')
  end
end
