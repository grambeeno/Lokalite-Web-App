# Production-specific deployment configuration
# please put general deployment config in config/deploy.rb

set :user, "lokalite"

ip = '184.173.113.115'
role :web, ip
role :app, ip
role :db,  ip, :primary => true

set :deploy_to, "/home/#{user}/#{application}"

