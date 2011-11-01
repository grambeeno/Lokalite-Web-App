# lokalite

## Dependencies

- Ruby 1.8.7 (an .rvmrc is included for use with [RVM](https://rvm.beginrescueend.com/))
- [Bundler](http://gembundler.com/)
- [PostgreSQL](http://www.postgresql.org/)

## Getting Started in Development

- Install gems with `bundle install`
- For Facebook integration, setup http://lokalite.dev with [Pow](http://pow.cx/) or by other means
- Create lokalite\_development db with with `rake db:create`
- Seed database and download images from production (instructions below)

## Deployment, Servers, and Database Management

We use [Capistrano](https://github.com/capistrano/capistrano/wiki) with the [Multistage extension](https://github.com/capistrano/capistrano/wiki/2.x-Multistage-Extension) for deployment and management of the development database, both locally and on the staging server.

The default environment is development, so `cap deploy` will be excecuted on the development server. For production you must specify with `cap production deploy`.

You need to have your SSH public key on the server for the deployment user. `lokalite` for production and `lokalitedev` for development.

You may want the following in your `~/ssh/config`:

    Host lokalite
      HostName lokalite.com
      User lokalite

    Host lokalite-dev
      HostName 72.249.171.49
      User lokalitedev

### Database Management

The production db is currently small enough that it makes sense to use it as a starting point for development. The images uploaded by users will also come down with the database, it will take a while at first but we use rsync so subsequent imports will not take as long.

You can import it to your local machine with `cap production backup:import`.

To import it to the development server, SSH into the server and to the current folder, then run `cap production backup && cap backup:import_to_production`.

The `~/db_dumps` folder on the server should be cleared manually from time to time.

