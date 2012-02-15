# See how all your routes lay out with "rake routes"
Lokalite::Application.routes.draw do |map|

  devise_for :users, :controllers => { :omniauth_callbacks => 'users/omniauth_callbacks' }

  match '/' => 'events#index', :constraints => { :subdomain => /list/ }, :fbview => '1', :category => 'featured', :origin => 'boulder-colorado'
  match '/' => 'slides#show', :constraints => { :subdomain => /information/ }
  match '/' => 'events#index', :constraints => { :subdomain => /m/ }, :format => 'mobile', :category => 'featured', :origin => 'boulder-colorado'
  match '/business' => 'root#business', :as => 'business_promo'
  devise_scope :user do
    match '/business/sign_up' => 'devise/registrations#new', :business => true, :as => 'business_sign_up'
  end

  resources :plans
  get 'plans/invitation/:id', :controller => 'plans', :action => 'show', :invitation => true, :as => 'plan_invitation'
  post 'plans/invitation/:id', :controller => 'plans', :action => 'accept_invitation', :as => 'accept_plan_invitation'
  match 'profile/datebook', :controller => 'plans', :action => 'new', :as => 'datebook'

  get 'profile/plans', :as => 'user_plans'
  get 'profile/edit', :as => 'edit_profile'
  post 'profile/update', :as => 'update_profile'

  # get "profile/suggestions", :as => 'suggestions'
  # get "profile/friends"

  match 'events/categories', :controller => :events, :action => :categories, :as => :event_categories

  get   'events/invitation/:id', :controller => :events, :action => :show, :invitation => true, :as => 'event_invitation'
  match 'events(/*slug)/:id', :as => :event, :controller => :events, :constraints => {:id => /\d+/}, :action => :show

  # match 'events/:origin(/category/:category)(/search/:keywords)', :controller => :events, :action => :index, :as => :events
  match 'events(/:view_type)/:origin(/category/:category)(/search/:keywords)', :as => :events, :controller => :events, :action => :index, :constraints => {:view_type => /map/}

  # match 'events(/:action(/:id(.:format)))', :as => :events, :controller => :events

  match 'places/categories', :controller => :places, :action => :categories, :as => :places_categories
  match 'places/random', :controller => :places, :action => :random_organization, :as => :random_organization
  match 'places/:name/:id', :controller => :places, :action => :organization, :constraints => {:id => /\d+/}, :as => :organization
  match 'places/:id', :controller => :places, :action => :organization, :constraints => {:id => /\d+/}
  match 'places/:origin(/category/:category)', :controller => :places, :action => :index, :as => :places

  match 'facebook/authorize', :controller => :facebook, :action => :authorize, :as => :facebook_authorize
  post 'facebook/ajax_request_handler', :controller => :facebook, :action => :ajax_request_handler, :as => :ajax_request_handler


  match 'my/events/feature', :controller => 'my/events', :action => :feature, :as => :manage_featured_events
  match 'my/events/unfeature/slot/:slot/date/:date', :controller => 'my/events', :action => :unfeature, :as => :unfeature_slot_on_date
  match 'my/events/events_for_organization/:organization_id', :controller => 'my/events', :action => 'events_for_organization'
  match 'my/events/featured_slots/:date', :controller => 'my/events', :action => 'featured_slots'

  namespace :my do
    resources :organizations do
      match 'add_user', :action => 'add_user', :as => :add_user
    end
    resources :events do
      put 'update_multiple', :action => 'update_multiple', :as => :update_multiple
      match 'repeat', :action => 'repeat', :as => :repeat
    end
  end

  match 'my/events/(:action(/:id(.:format)))', :controller => 'my/events', :as => 'my_events'
  # match 'my/organizations/:id/(:action)', :controller => 'my/organizations', :as => 'my_organization', :constraints => {:id => /\\d+/}
  # match 'my/organizations/(:action(/:id(.:format)))', :controller => 'my/organizations', :as => 'my_organizations'
  match 'my/(:action(/:id(.:format)))', :controller => 'my', :as => 'my'

  map.sitemap '/sitemap.xml', :controller => 'sitemap', :action => 'index'
  match 'sitemap(/:action(.:format))', :controller => 'sitemap'

  match 'api/:api_version' => 'api#index', :as => 'api_index', :constraints => {:api_version => /\d+/}
  match 'api/:api_version/*path' => 'api#call', :as => 'api', :constraints => {:api_version => /\d+/}


  match 'static(/:action(.:format))', :controller => 'static', :as => 'static'

  match 'test(/:action(/:id(.:format)))', :controller => 'test', :as => 'test'

  namespace(:admin) do
    match 'users(/:action(/:id(.:format)))', :controller => 'users'
  end

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'

  match '/landing', :controller => 'root', :action => 'landing'
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "root#index"
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
