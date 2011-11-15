require 'capistrano/ext/multistage'
require "bundler/capistrano"

# You can deploy if you have a public key in /home/#{user}/.ssh/authorized_keys

set :stages, %w(development staging production)
set :default_stage, "development"

set :branch, "mobile_view"

set :application, "lokalite"

set :use_sudo, false

set :scm, :git
set :repository,  "git@github.com:grambeeno/Lokalite-Web-App.git"
set :deploy_via, :remote_cache
set :deploy_env, 'production'

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

