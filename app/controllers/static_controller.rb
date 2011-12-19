class StaticController < ApplicationController
  def StaticController.pages
    unless defined?(@pages)
      @pages = []
      glob = File.join(Rails.root, 'app/views/static/*')

      Dir.glob(glob).each do |pathname|
        dirname, basename = File.split(pathname)
        page, format = basename.split(%r/[.]/, 2).first.to_sym
        @pages.push(page)
      end
    end
    @pages
  end

  StaticController.pages.each do |page|
    module_eval <<-__, __FILE__, __LINE__
      def #{ page }() end
      caches_action(#{ page.inspect })
    __
  end

  def send_mail
    Mailer::contact_email(params[:email]).deliver
    redirect_to '/static/contact'
    flash[:notice] = 'Thanks for your email.'
  end

  def send_advertise_mail 
    Mailer::advertise_email(params[:email]).deliver
    redirect_to '/static/advertise'
    flash[:notice] = 'Your email has been sent, we will get back to you shortly.'
  end
end
