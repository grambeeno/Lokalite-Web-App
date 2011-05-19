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
end
