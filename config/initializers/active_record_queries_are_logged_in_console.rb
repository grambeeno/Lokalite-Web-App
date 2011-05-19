if defined?(ActiveRecord)
# log queries to stderr when running in the console
#
  program = File.basename(File.expand_path($0))

  #if Rails.env.development? and STDIN.tty? and %w' irb rails '.include?(program)
  
  if defined?(Rails::Console)
    ActiveRecord::Base.logger = Logger.new(STDERR) unless ENV['RAILS_QUIET']
  end
end
