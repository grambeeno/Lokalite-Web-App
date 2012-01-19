# DEVELOPMENT-specific deployment configuration
# please put general deployment config in config/deploy.rb

set :user, "lokalitedev"

ip = '184.173.113.114'
role :web, ip
role :app, ip
role :db,  ip, :primary => true

set :deploy_to, "/home/#{user}/#{application}"

