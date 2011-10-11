set :application, 'lokalite'

set :user, "lokalite"
set :domain, "lokalite.com"

set :db_dir, "~/db_dumps"
set :filename, "#{application}_$(date \'+%Y-%m-%d@%Hh%M\').sql"
set :destination, "#{db_dir}/#{filename}"

namespace :backup do

  desc "Backup production db and import to development db"
  task :default do
    backup
    sync_to_local
    import
  end

  desc "Backup production and sync to local system without importing to development"
  task :no_import do
    backup
    sync_to_local
  end

  desc "Backup production db to the server"
  task :backup do
    run "pg_dump --clean -O -f #{destination} #{application}_production"
    # run "gzip #{destination}"
  end

  desc "Syncs DB backups from the server to local system"
  task :sync_to_local do
    system "rsync -vr #{user}@#{domain}:db_dumps/ db_dumps/"
    system "rsync -vr #{user}@#{domain}:#{application}/current/public/system/ public/system/"
  end

  desc "Imports production db into development"
  task :import do
    # identify most recent local backup and import it
    system "recent_db_backup=`ls -1 db_dumps/ | tail -1`
    psql -f db_dumps/`echo $recent_db_backup` lokalite_development lokalite"
  end

end
