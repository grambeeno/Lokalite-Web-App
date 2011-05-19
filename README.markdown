## http://dojo4.com

  this is not a lovesong


## get going

  * NOW

    * clone the app
        git clone git@github.com:dojo4/lokalite.git ./my_app

    * rename the app
        rake app:rename src=lokalite dst=my_app

    * nuke the old .git dirs
        rm -rf .git

    * thid's be a good point to check into github...
        (git stuff)

    * rake db:createuser && rake db:create && rake db:migrate
        or similar.  suckier if you're using mysqeal.

  * LATER

    * edit email settings in config/initializers/action_mailer.rb

    * set google analitics code variables

    * create an favicon.ico

    * create an apple-touch-icon.png



## features 

  * ability to rename the application
    * rake app:rename NewApp
    * rake app:rename src=OldApp dst=NewApp

  * a sane .gitignore

  * setup for --database=postgresl

  * json support via yajl

  * jquery ujs support baked in

  * built-in root controller at root route

  * ability to multiplex layouts based variable/params/default

  * current_controller support (global knowledge of current request/controller)

  * helper object support (helpers from anywhere)

  * non-shitty local_request definition

  * a test controller for checking things out realtime

  * auto-rolling logs via logging.rb gem

  * slug support via slug.rb

  * support for pre-initializers

  * support for url safe (modified base64) encryption (openssl/aes-256)

  * support for auto configured default_url_options

  * static assets can be served in production to support localhost testing

  * a magic Helper class that allows using helpers anywhere in the context of the current request

  * support for compound RAILS_ENV / RAILS_STAGE settings.  RAILS_ENV=production_staging

  * app auto configures for x_sendfile based on being behind apache or nginx

  * support for RAILS_ROOT/private/system (via X-Send-File)

  * support for flash messages generated from rails and/or javascript
      App.flash('a message to you!')

  * jquery template shortcuts
      <script class='template' name='template-name' type='text/x-jquery-tmpl'> ... </script>
      App.templates['template-name']

  * a rake task for backing up the application db as yaml plus assets located
    (configurably) under RAILS_ROOT/private/

  * persistent database sessions associated with each user, accessible from
    outside any http context

  * a static controller for serving rarely changing hunks of templated html

  * some half way decent form styles

  * some js initializer code (App.initialze) which can be extended to initialize lightboxen, etc. easily

  * active_record is configured to log sql when in console/tty mode

  * ssl_requiremnt plugin installed

  * formatstic plugin installed

  * carrierwave file upload plugin

  * aupport for vendor/gems
      rake vendor:gem gem=map version=2.2.0





## refs
 
  * http://daringfireball.net/projects/markdown/syntax

