load 'deploy' if respond_to?(:namespace) # cap2 differentiator

Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }



### bundler (require 'bundler/capistrano.rb')
#
  namespace :bundle do
    task :symlinks, :roles => :app do
      shared_dir = File.join(shared_path, 'bundle')
      release_dir = File.join(current_release, '.bundle')
      run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
    end

    task :install, :except => { :no_release => true } do
      bundle_dir     = fetch(:bundle_dir,         " #{fetch(:shared_path)}/bundle")
      bundle_without = [*fetch(:bundle_without,   [:development, :test])].compact
      bundle_flags   = fetch(:bundle_flags, "--deployment --quiet")
      bundle_gemfile = fetch(:bundle_gemfile,     "Gemfile")
      bundle_cmd     = fetch(:bundle_cmd, "bundle")

      args = ["--gemfile #{fetch(:latest_release)}/#{bundle_gemfile}"]
      args << "--path #{bundle_dir}" unless bundle_dir.to_s.empty?
      args << bundle_flags.to_s
      args << "--without #{bundle_without.join(" ")}" unless bundle_without.empty?

      run "#{bundle_cmd} install #{args.join(' ')}"
    end
  end
  after 'deploy:update_code', 'bundle:symlinks'
  after "deploy:update_code", "bundle:install"


### multistage (require 'capistrano/ext/multistage')
#
  set :stages, %w( staging production )
  set :default_stage, "staging"

 ### require 'capistrano/ext/multistage'

  location = fetch(:stage_dir, "config/deploy")
  unless exists?(:stages)
    set :stages, Dir["#{location}/*.rb"].map { |f| File.basename(f, ".rb") }
  end
  stages.each do |name| 
    desc "Set the target stage to `#{name}'."
    task(name) do 
      set :stage, name.to_sym 
      load "#{location}/#{stage}" 
    end 
  end 
  namespace :multistage do
    desc "[internal] Ensure that a stage has been selected."
    task :ensure do
      if !exists?(:stage)
        if exists?(:default_stage)
          logger.important "Defaulting to `#{default_stage}'"
          find_and_execute_task(default_stage)
        else
          abort "No stage specified. Please specify one of: #{stages.join(', ')} (e.g. `cap #{stages.first} #{ARGV.last}')"
        end
      end 
    end
    desc "Stub out the staging config files."
    task :prepare do
      FileUtils.mkdir_p(location)
      stages.each do |name|
        file = File.join(location, name + ".rb")
        unless File.exists?(file)
          File.open(file, "w") do |f|
            f.puts "# #{name.upcase}-specific deployment configuration"
            f.puts "# please put general deployment config in config/deploy.rb"
          end
        end
      end
    end
  end
  on :start, "multistage:ensure", :except => stages + ['multistage:prepare']
