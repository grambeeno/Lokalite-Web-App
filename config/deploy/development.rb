# DEVELOPMENT-specific deployment configuration
# please put general deployment config in config/deploy.rb

set :user, "lokalitedev"

ip = '72.249.171.49'
role :web, ip
role :app, ip
role :db,  ip, :primary => true

set :deploy_to, "/home/#{user}/#{application}"

