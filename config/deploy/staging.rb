# STAGING-specific deployment configuration
# please put general deployment config in config/deploy.rb

set :user, "lokalite"

ip = '174.136.1.78'
role :web, ip
role :app, ip
role :db,  ip, :primary => true

set :deploy_to, "/home/#{user}/#{application}"

