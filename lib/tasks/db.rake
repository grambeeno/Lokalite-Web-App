namespace(:db) do
  desc "select postgresql|sqlite3"
  task(:select, :database) do |task, options|
    ## setup
    #
      options.with_defaults(
        :database  => (ENV['database']  || ENV['DATABASE'])
      )
      database = options[:database]

      abort('no DATABASE!') unless database 

      dst = File.join(Rails.root, 'config', 'database.yml')
      src = dst + ".#{ database }"
      FileUtils.rm(dst)
      FileUtils.cp(src, dst)
      puts "#{ src } #=> #{ dst }"
  end

  desc "db:drop && db:create && db:migrate"
  task(:bounce => %w(db:drop db:create db:migrate)) do
  end

  desc "a task which creates the database user"
  task(:createuser => :load_config) do
    config = ActiveRecord::Base.configurations
    config = config[Rails.env] || config
    adapter = config['adapter']
    username = config['username']
    password = config['password']

    case adapter
      when /postgres/
        require 'pty'
        require 'expect'
        command = "createuser --superuser #{ username.inspect }"
        command += " --password" if password
        PTY.spawn(command) do |r,w,pid|
          w.sync = true
          if password
            r.expect(/^\s*password:\s*/i)
            w.puts(password)
          end
          while r.gets
          end
        end

      when /mysql/
        warn "you should be using postgresql!"
    end
  end

  desc "show the db config"
  task(:config => :load_config) do
    y  ActiveRecord::Base.configurations
  end

  desc "a task which drops the database user"
  task(:dropuser => :load_config) do
    config = ActiveRecord::Base.configurations
    config = config[Rails.env] || config
    adapter = config['adapter']
    username = config['username']
    password = config['password']

    case adapter
      when /postgres/
        require 'pty'
        require 'expect'
        command = "dropuser #{ username.inspect }"
        PTY.spawn(command) do |r,w,pid|
          w.sync = true
          if password
            r.expect(/^\s*password:\s*/i)
            w.puts(password)
          end
          while r.gets
          end
        end

      when /mysql/
        warn "you should be using postgresql!"
    end
  end
  task('db:create' => %w( db:createuser )){}
end


__END__

#
# sample program of expect.rb
#
#  by A. Ito
#
#  This program reports the latest version of ruby interpreter
#  by connecting to ftp server at ruby-lang.org.
#
require 'pty'
require 'expect'

fnames = []
PTY.spawn("ftp ftp.ruby-lang.org") do |r_f,w_f,pid|
  w_f.sync = true
  
  $expect_verbose = false
  
  if !ENV['USER'].nil?
    username = ENV['USER']
  elsif !ENV['LOGNAME'].nil?
    username = ENV['LOGNAME']
  else
    username = 'guest'
  end
  
  r_f.expect(/^(Name).*: |(word):|> /) do
    w_f.puts($1 ? "ftp" : $2 ? "#{username}@" : "cd pub/ruby")
  end
  r_f.expect("> ") do
    w_f.print "dir\n"
  end
  
  r_f.expect(/[^\-]> /) do |output|
    for x in output[0].split("\n")
      if x =~ /(ruby.*?\.tar\.gz)/ then
         fnames.push $1
      end
    end
  end
  begin
    w_f.print "quit\n"
  rescue
  end
end

print "The latest ruby interpreter is "
print fnames.sort.pop
print "\n"
