namespace :events do
  task :index do
    Event.index!
  end
end
