module DirectoryHelper

  def places_index_page?
    params[:controller] == 'places' && params[:action] == 'index'
  end

end
