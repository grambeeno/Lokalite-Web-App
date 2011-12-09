set :application, 'lokalite'

set :user, "lokalite"
set :domain, "lokalite.com"

set :db_dir, "~/db_dumps"
set :filename, "#{application}_$(date \'+%Y-%m-%d@%Hh%M\').sql"
set :destination, "#{db_dir}/#{filename}"

namespace :backup do

  desc "Backup production db and sync the db dump and images to local machine"
  task :default do
    backup
    sync_to_local
  end

  desc "Backup production, sync to local machine, and import to development database"
  task :import do
    backup
    sync_to_local
    import_to_development
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

  desc "Import production db into development environment"
  task :import_to_development do
    # clear out the schema. Even though we exported with --clean there may be
    # other tables added in migrations during development
    system "psql -c 'DROP SCHEMA public CASCADE;' lokalite_development lokalite"
    # identify most recent local backup and import it
    system "recent_db_backup=`ls -1 db_dumps/ | tail -1`
    psql -f db_dumps/`echo $recent_db_backup` lokalite_development lokalite"
  end

  desc "Import production db into production environment"
  # this is used for bringing the production db into our staging environment (running in production mode)
  task :import_to_production do
    system "psql -c 'DROP SCHEMA public CASCADE;' lokalite_production lokalite"
    system "recent_db_backup=`ls -1 db_dumps/ | tail -1`
    psql -f db_dumps/`echo $recent_db_backup` lokalite_production lokalite"
  end

end
