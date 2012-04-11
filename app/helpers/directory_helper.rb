module DirectoryHelper

  def places_page?
    params[:controller] == 'places'
  end

end
