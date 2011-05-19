### require 'config/capistrano_database_yml'
#


set :application, "lokalite"
set :repository,  "git@github.com:dojo4/lokalite.git"
set :user, "dojo4"
set :deploy_to, "/ebs/apps/#{ application }"

set :scm, :git
set :deploy_via, :remote_cache

# be sure to run 'ssh-add' on your local machine
system "ssh-add 2>&1" unless ENV['NO_SSH_ADD']
ssh_options[:forward_agent] = true

set :deploy_via, :remote_cache
set :branch, "master"
set :use_sudo, false

#ip = "lokalite.dojo4.com"
ip = "lokalite.app.dojo4.com"
role :web, ip                          # Your HTTP server, Apache/etc
role :app, ip                          # This may be the same as your `Web` server
role :db,  ip, :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
