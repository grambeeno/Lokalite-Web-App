# See how all your routes lay out with "rake routes"
Lokalite::Application.routes.draw do
# event routes
#
  match 'event(/*slug)/:id', :as => :event, :controller => :events, :constraints => {:id => /\d+/}, :action => :show

  match 'events/location/*location/category/:category/date/:date', :controller => :events, :action => :browse
  match 'events/location/*location/category/:category', :controller => :events, :action => :browse
  match 'events/location/*location/date/:date', :controller => :events, :action => :browse
  match 'events/location/*location', :controller => :events, :action => :browse
  match 'events(/location/*location(/category/:category(/date/:date)))', :as => :events_location, :controller => :events, :action => :browse

  match 'events/organization/:organization/category/:category/date/:date', :controller => :events, :action => :browse
  match 'events/organization/:organization/category/:category', :controller => :events, :action => :browse
  match 'events/organization/:organization/date/:date', :controller => :events, :action => :browse
  match 'events/organization/:organization', :controller => :events, :action => :browse
  match 'events(/organization/:organization(/category/:category(/date/:date)))', :as => :events_organization, :controller => :events, :action => :browse

  match 'events(/:action(/:id(.:format)))', :as => :events, :controller => :events

# directory routes
#
  # match 'directory/location/*location/:name/:id', :controller => :directory, :action => :organization, :constraints => {:id => /\\d+/}
  # match 'directory/location/*location/category/:category', :controller => :directory, :action => :browse
  # match 'directory/location/*location', :controller => :directory, :action => :browse
  # match 'directory/:id', :controller => :directory, :action => :browse
  # match 'directory(/:action(/:id(.:format)))', :as => :directory, :controller => :directory

  #match 'account(/:action(/:id(.:format)))', :as => :account, :controller => :account

  match 'places/random', :controller => :directory, :action => :random_organization, :as => :random_organization
  match 'places/:name/:id', :controller => :directory, :action => :organization, :constraints => {:id => /\d+/}, :as => :organization

  namespace :my do
    resources :organizations do
      match 'statuses' => 'organizations#statuses'
    end
    resources :events
  end

  match 'my/events/(:action(/:id(.:format)))', :controller => 'my/events', :as => 'my_events'
  # match 'my/organizations/:id/(:action)', :controller => 'my/organizations', :as => 'my_organization', :constraints => {:id => /\\d+/}
  # match 'my/organizations/(:action(/:id(.:format)))', :controller => 'my/organizations', :as => 'my_organizations'
  match 'my/(:action(/:id(.:format)))', :controller => 'my', :as => 'my'

  match 'my/profile', :controller => 'my', :action => 'profile', :as => 'edit_profile'

  match 'api' => 'api#index', :as => 'api_index'
  match 'api/*path' => 'api#call', :as => 'api'


  #StaticController.pages.each do |page|
    #match "static/:page(.:format)", :controller => 'static', :action => :method_missing, :as => 'static'
  #end
  match 'static(/:action(.:format))', :controller => 'static', :as => 'static'
  #match "static/:page(.:format)", :controller => 'static', :action => 'compile_page', :as => 'static'

  match '/business' => 'auth#signup', :business => true, :as => 'business_signup'
  match '/signup(/:token)' => 'auth#signup', :as => 'signup'
  match '/auth/:action(/:token)', :controller => 'auth', :as => 'auth'
  match '/activate(/:token)' => 'auth#activate', :as => 'activate'
  match '/login(/:token)' => 'auth#login', :as => 'login'
  match '/logout' => 'auth#logout', :as => 'logout'
  match '/password(/:token)' => 'auth#password', :as => 'password'
  # match '/set_location/(*prefix)' => 'root#set_location', :as => 'set_location'

  match 'test(/:action(/:id(.:format)))', :controller => 'test', :as => 'test'

  match 'raptcha(/:action)', :controller => 'raptcha'

  namespace(:admin) do
    match 'users(/:action(/:id(.:format)))', :controller => 'users'
  end

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "events#browse"
end

# The priority is based upon order of creation:
# first created -> highest priority.

# Sample of regular route:
#   match 'products/:id' => 'catalog#view'
# Keep in mind you can assign values other than :controller and :action

# Sample of named route:
#   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
# This route can be invoked with purchase_url(:id => product.id)

# Sample resource route (maps HTTP verbs to controller actions automatically):
#   resources :products

# Sample resource route with options:
#   resources :products do
#     member do
#       get 'short'
#       post 'toggle'
#     end
#
#     collection do
#       get 'sold'
#     end
#   end

# Sample resource route with sub-resources:
#   resources :products do
#     resources :comments, :sales
#     resource :seller
#   end

# Sample resource route with more complex sub-resources
#   resources :products do
#     resources :comments
#     resources :sales do
#       get 'recent', :on => :collection
#     end
#   end

# Sample resource route within a namespace:
#   namespace :admin do
#     # Directs /admin/products/* to Admin::ProductsController
#     # (app/controllers/admin/products_controller.rb)
#     resources :products
#   end
