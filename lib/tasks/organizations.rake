namespace :organizations do
  task :index do
    Organization.index!
  end
end
