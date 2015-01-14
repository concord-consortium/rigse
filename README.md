CC Rails Portal Activity Authoring, Deployment, and Reporting System
====================================================================
[![Code Climate](https://codeclimate.com/github/concord-consortium/rigse.png)](https://codeclimate.com/github/concord-consortium/rigse)

Setup
-----

### Prerequisites

Working git, ruby or jruby, and rubgems, wget
Gems: capistrano, capistrano-ext, ruby-debug (oddly, haml too, when
deploying …)
TODO: understand why running capistrano requires haml…

### Install

The latest setup scripts have been tested with 1.4.0RC1 of JRuby, you
will need a running mysql
server and a mysql username/password with enough permissions to create
and drop the
database you intend to use with RITES.

#### RVM, Bundler, & Gem Dependencies

-   [Maintaining gem dependencies](doc/gem-dependencies.textile)

#### Updating to a newer codebase.

-   Example of [updating an older instance to to newer
    code](doc/updating_an_older_instance.md)

#### Core Extensions

-   [Extensions to core classes applied at application
    startup](doc/core-extensions.textile)

#### Setting up a Hudson CI project

-   [Setting up a Hudson CI project](doc/hudson-ci.textile)

#### GIT

In the example below we use the xproject theme and also as the name of
the directory and
the prefix of the names for the databases that will be created in mysql.

If you are a committer in this repo:

    git clone git@github.com:concord-consortium/rigse.git xproject

If you are not a committer:

    git clone git://github.com/concord-consortium/rigse.git xproject

Change to the project directory:

    cd xproject

Setup rvm to use Ruby 1.9.3-p125 and a gemset named xproject
(newer versions of 1.9.3 ought to work as well)

    rvm use 1.9.3-p125
    rvm gemset create xproject

Make an `.rvmrc` file so rvm will use this ruby gemset combo
automatically when you change to this directory:

    echo "rvm use 1.9.3-p125@xproject" > .rvmrc

Test out the `.rvmrc` file and start using the gemset

    cd ..;cd xproject

Install [bundler](http://gembundler.com/)
(typically rvm will install bundler for you when you install ruby)

    gem install bundler

Install the precise versions of the required gems and put the
executables in bin/

    bundle install --binstubs

If you get the following error

    An error occurred while installing libv8 (3.16.14.3), and Bundler cannot
    continue.
    Make sure that `gem install libv8 -v '3.16.14.3'` succeeds before bundling.

 To resolve the error install libv8 sepratelly with --with-system-v8

	gem install libv8 -v '3.16.14.3' -- --with-system-v8

If you get the following error

	An error occurred while installing therubyracer (0.12.1), and Bundler cannot
	continue.
	Make sure that `gem install therubyracer -v '0.12.1'` succeeds before bundling.

Replace `gem 'therubyracer',         "~>0.12.1"` entry in the Gemfile to `gem 'therubyracer',         "~>0.10.2"`

Automatic setup of application settings in the config directory, for
example: settings.yml and database.yml

    ruby config/setup.rb --name "Cross Project Portal" --database xproject --user <dbuser> --password <password> --theme xproject --states none --yes --quiet --force

The option `--states none` means that only a single virtual district and
school will be created.

If you leave this option out the default is to create portals instances
for all the districts and schools in Massachusetts.

You can also supply a comma-delimited list of two character
abbreviations for states or provinces:

    --states RI,CT

The options `-y -q -f` to setup mean:

-   `-y` automatically answer 'yes' to accept default values
-   `-q` use 'quieter' console output
-   `-f` force an update of the existing settings.yml and database.yml
    if they exist

Setup database.

If this fails it is probably due to a bad mysql gem install, check out
the [RVM page on database
integration](https://rvm.beginrescueend.com/integration/databases/) for
help. You might get a warning if the databases already exist.

    RAILS_ENV=development rake db:create:all
    RAILS_ENV=development rake db:migrate:reset
    RAILS_ENV=development rake db:backup:load_probe_configurations

Start solr (requires Java, on Mac OS X this command should cause a installating prompt to appear)

    RAILS_ENV=development rake sunspot:solr:start

Setup application resources

    RAILS_ENV=development rake app:setup:create_default_data

Save a copy of the development database to make subsequent clean starts
much quicker (bypassing rake app:setup:new_app).

* Saves database to: db/development_data.sql
* can be reloaded later with: rake db:load
* note: in default setup created by config.rb above the development and production database is the same

    rake db:dump

This project uses the rails [asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html)
to manage static assets, and JS & CSS files. There are rake commands for compiling these assets,
but they should run automatically when on 'cap deploy' because capistrano knows about the asset pipeline.

You may also run the asset packing task manually however:

    rake assets:clean # Remove compiled assets
    rake assets:precompile # Compile all the assets named in
    config.assets.precompile

This will build all the assets within the project.

Start server and open [http://localhost:3000](http://localhost:3000)

    rails s -edevelopment

You can read this documentation at:
[http://localhost:3000/readme](http://localhost:3000/readme)

After getting the server running it's good to confirm that all the tests
pass before changing any code.

Prepare a database for use when running the tests:

    rake db:test:prepare

Run the rspec unit tests:

    rake spec

Run the cucumber integration tests:

    rake cucumber

All these tests should pass. If you add features make sure and add tests
for these new features.

### Theme support & Rolling your own theme:

We are using the
[themes_for_rails](https://github.com/lucasefe/themes_for_rails) gem
Theme views go in app/themes/(name)/views/
Theme assets go in app/assets/theme/(name)/
Sample config files go in config/themes/(name)/settings.sample.yml

For now the best thing to do is to copy an existing theme. eg:

    mkdir ./config/themes/<new_theme_name>

    # configuration files:
    cp ./config/themes/<old_theme_name>/settings.sample.yml
    ./config/themes/<new_theme_name>

    # view files:
    cp -r ./themes/<old_theme_name> ./themes/<new_theme_name>

    # assets:
    cp -r ./app/assets/themes/<old_theme_name>
    ./app/assets/themes/<new_theme_name>

    # then pass arguments to setup.
    ruby ./config/setup.rb  -t <new_theme_name>


### when deploying to a new server

1. create required directories on your server eg:
    1. /web/production/APP_NAME/shared/log
    1. /web/production/APP_NAME/shared/config
    1. /web/production/APP_NAME/shared/initializers
    1. /web/production/APP_NAME/releases
1. put configuration files in /web/production/APP_NAME/shared/config
    1. at a minimum you need database.yml
1. modify the deploy recipies
1. deploy cap deploy ( it will fail, but it will get far enough to make
some of the other things below possible)
1. run ruby config/setup.rb on the server
1. comment out the one line in config/initializers/rites.rb
1. make sure config/nces_data isn't there
1. run RAILS_ENV=production rake rigse:setup:new_rites_app


*there's a bunch more that needs to go here*

## Copying the production database to a development environment

If you have ssh access to a portal instance running on a server you can
get a copy of the database on
your local development instance with the following steps:

In the code below *stage* means a capistrano stage that identifies a
remote server. For example **xproject-dev**.

     cap <stage> db:fetch_remote_db
     RAILS_ENV=production jruby -S rake db:load

If the codebase on your development system has moved forward you may
need to run additional tasks such as:

    RAILS_ENV=production jruby  -S rake db:migrate
    RAILS_ENV=production jruby -S rake
    rigse:setup:default_portal_resources
    RAILS_ENV=production jruby  -S rake
    portal:setup:create_districts_and_schools_from_nces_data


The task: `default_users_roles_and_portal_resources` is last on that
list because code changes may have added additional and necessary
default model initialization.

In order for the same passwords to work you will also need to have the
same *pepper* in your local config/settings.yml as on the server you
copied the production data from.

Recreating a new portal instance from scratch from an existing
application.

    rake db:drop:all
    git clean -fXd
    jruby config/setup.rb
    jruby  -S rake gems:install
    RAILS_ENV=production jruby -S rake rigse:setup:new_rites_app

The ' -fxd' parameters to to git clean:

* -d: Remove untracked directories in addition to untracked files.
* -X: Remove only files ignored by git.
* -f: force removal

### Setting up a local JNLP Web Start servlet

You can also setup a local jnlp web start server for a development
environment with less dependence on outside services.

* [Setup a Full SAIL Stack on Mac OS 10.5](https://confluence.concord.org/display/CSP/Setup+a+Full+SAIL+Stack+on+MacOS+10.5*)
has several sections with useful information:

* [Install Jnlp Servlet and build associated WAR file with jnlp and
jars](https://confluence.concord.org/display/CSP/Setup+a+Full+SAIL+Stack+on+MacOS+10.5#SetupaFullSAILStackonMacOS10.5-4InstallJnlpServletandbuildassociatedWARfilewithjnlpandjars)

## NCES District and School Tables

When a rails-portal instance is created two tables containing data for
schools and districts in the US are created from data supplied by the
[National Center for Education Statistics (NCES)](http://nces.ed.gov/).

NCES maintains a database about US districts and schools called the
[Common Core of Data](http://nces.ed.gov/ccd)

The rake task:
`portal:setup:create_districts_and_schools_from_nces_data`
downloads 2006 NCES CCD data files from NCES website and imports data
from these data files into the following models:

* `Portal::Nces06District`
* `Portal::Nces06School`

Only data from states and provinces identified in the
`config/settings.yml` for the portal instance are imported.

The NCES district and school models are used to provide data from which
districts and schools actively using the portal are be created.

The `Portal::Nces06District` includes about 50 different fields of data
for each district.

The `Portal::Nces06School`includes about 500 different fields of data
for each school.

### PDF documentation for the NCES data schemas

* [NCES Common Core of Data Public Elementary/Secondary School Universe
Survey: School Year 2006–07, Version
1b](http://nces.ed.gov/ccd/pdf/psu061bgen.pdf)
* [NCES Common Core of Data Local Education Agency Universe Survey:
School Year 2006–07](http://nces.ed.gov/ccd/pdf/pau061bgen.pdf)

## Testing

### Testing Frameworks

#### Rspec, Rspec-rails

* [rspec and rspec-rails](http://rspec.info/)
 * [rspec repo](http://github.com/dchelimsky/rspec)
 * [rspec-rails repo](http://github.com/dchelimsky/rspec-rails)

#### Cucumber


#### Capybara

You can customize your selenium drivers by editing @ ~/.capybara.rb @
This file is sourced by @ ./features/support/local_config.rb @

Here is a sample file which checks for an ENV param named @
SELENIUM_CONFIG @


    case ENV
    when 'saucelabs-ie'
        Capybara.server_port = ENV.to_i
        Capybara.app_host = "http://app#{Capybara.server_port}.test.dev.concord.org"
        selenium_remote :url => "http://ccdev:[aebecf9c-b426-44f8-9726-6eb747a7340e@ondemand.saucelabs.com](mailto:aebecf9c-b426-44f8-9726-6eb747a7340e@ondemand.saucelabs.com):80/wd/hub",
        :desired_capabilities => Selenium::WebDriver::Remote::Capabilities.internet_explorer
    when 'ff6'
        puts " ----- using Firefox 6 profile -----"
        Selenium::WebDriver::Firefox.path= '/usr/local/bin/firefox6'
        Capybara.register_driver :selenium do |app|
            Capybara::Selenium::Driver.new
        end
    when 'chrome'
        puts "----- using Chrome profile -----"
        Capybara.register_driver :selenium do |app|
            Capybara::Selenium::Driver.new
        end
    else
        # by default don't customize anything, this ought to keep the current
        capybara tests running as before
        #
    end

#### Factory Girl

> factory_girl allows you to quickly define prototypes for each of
your models and ask for instances with properties that are important to
the test at hand.

* [Factory Girl](http://thoughtbot.com/projects/factory_girl)
 * [Factory Girl repo](http://github.com/thoughtbot/factory_girl)
 * [Factory Girl
introduction](http://robots.thoughtbot.com/post/159807023/waiting-for-a-factory-girl)
* [Factory Girlrdoc](http://rdoc.info/projects/thoughtbot/factory_girl)

### Using Nokogiri with JRuby on Mac OS X

Some of the testing frameworks depend on Nokogiri which is a Ruby html
and xml parsing gem that uses the C-based libxml2 library.

When Nokogiri runs in JRuby it uses [Ruby
FFI](http://kenai.com/projects/ruby-ffi) to dynamically load the libxml2
shared library.

The version of libxml2 included with MacOS X is old and the FFI version
of Nokogiri prints this warning when it is run with this version of
libxml installed:

> You're using libxml2 version 2.6.16 which is over 4 years old and
has plenty of bugs. We suggest that for maximum HTML/XML parsing
pleasure, you upgrade your version of libxml2 and re-install nokogiri.
If you like using libxml2 version 2.6.16, but don't like this warning,
please define the constant
I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2 before
requring nokogiri.

If you have a newer version of the libxml2 library installed with
macports you can set this environmental variable:
`LD_LIBRARY_PATH=/opt/local/lib` to have nokogiri check there for shared
libraries first.

See: [libxml2 for Nokogiri in
JRuby](http://www.practicalguile.com/2009/06/07/libxml2-for-nokogiri-in-jruby/)

> Nokogiri uses Ruby FFI to dynamically load native C code and FFI
makes use of dlopen to do the actual loading of dynamic libraries. On
OSX, dlopen searches for files specified by a couple of environment
variables , and the current working directory. Setting LD_LIBRARY_PATH
to /opt/local/lib worked for me. There may be differences in the
environment variables used for dlopen on different platforms, so a look
at the MAN pages would be a good idea if things don't seem to work.

### Running the rspec tests

**JRuby invocation note**: use this command prefix to run the rake spec
tests from JRuby if you have a more recent version of libxml2 installed
with macports:

> `LD_LIBRARY_PATH=/opt/local/lib jruby -S rake spec ` *options*

**Running all the rspec tests:*

    rake spec

**Running a single file:**

    rake spec SPEC=spec/routing/dataservice/bundle_contents_routing_spec.rb

**Running a single directory:**

    rake spec SPEC=spec/routing/dataservice

**Running all the controller tests:**

    rake spec SPEC=spec/controllers

### Running the feature tests with cucumber

**JRuby invocation note**: use this command prefix to run the rake spec
tests from JRuby if you have a more recent version of libxml2 installed
with macports: `LD_LIBRARY_PATH=/opt/local/lib jruby -S`

**Running all the feature tests:**
    rake cucumber

**Running all the feature tests using the ci_reporter gem that's used
on the hudson CI system:**
    rake hudson:cucumber

**Running a single feature:**
    rake cucumber
FEATURE=features/student_can_not_see_deactivated_offerings.feature

## Understanding the Codebase


### Some video walk-throughs

* [The Page Elements Model Part I](http://screencast.com/t/8M2ISjcM)
* [Page Elements Model Part II](http://screencast.com/t/YyqOHfItL)
* [HAML, Compass and SASS](http://screencast.com/t/68yJOeCRcN)
* [PageElement View partials](http://screencast.com/t/800TVxOC)
* [HAML, Compass and SASS](http://screencast.com/t/68yJOeCRcN)
* [Javascript use in Portal](http://screencast.com/t/z7Vkt32iTp)

---

### The Page Elements Model Part I:

screencast: [The Page Elements Model PartI](http://screencast.com/t/8M2ISjcM)

Install github version of railroad with aasm patches from [ddolar's
repo](http://github.com/ddollar/railroad/tree/master)

Generate a graph of the projects models using railroad:
    railroad -o models.dot  -M


Open that file with omnigraffle, or traslate to some other image format
using the dot tool.

 ---

### Page Elements Model Part II:

screencast: [Page Elements Model PartII](http://screencast.com/t/YyqOHfItL)

Using mysql query browser to view schema:
[Mysql
gui-tools](http://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-gui-tools-5.0-r12-osx10.4-universal.dmg/from/pick)

Use the generator to generate page elements eg:

    ./script/generate element xhtml content:text


 ---

### PageElement View partials:

screencast: [PageElement View partials](http://screencast.com/t/800TVxOC)

Shows the relationship between:
* pages/show.html.haml
* pages/element_container.html.haml
* shared/_embeddable_container.html.haml
* <embeddable_type>/_show.html.haml

 ---

### HAML, Compass and SASS:

screencast: [HAML, Compass and SASS](http://screencast.com/t/68yJOeCRcN)

Brief introduction to the technologies generally, and how we use them
specifically

* [HAML & SASS](http://haml.hamptoncatlin.com/)
* [Compass: http](http//compass-style.org/)
* [BluePrint: http](http//www.blueprintcss.org/)


----

### Javascript use in Portal

screencast: [Javascript use in Portal](http://screencast.com/t/z7Vkt32iTp)

Javascript librararies we are using, and what things we have written by
ourselves;
Stuff we did:
* accordion view
* drop-downs
Other libraries
* [prototype](http://www.prototypejs.org/)
* [scriptaculous](http://script.aculo.us/)
* [tinymce](http://tinymce.moxiecode.com/)
* [flotr](http://solutoire.com/flotr/)

## Capistano Tasks:

- [Capistrano Deployment Recipes](doc/cap-tasks.md)


## Updating a staging server.

Once a development branch has been deployed to a development server,
tested
and found reliable enough to deploy to staging here's how to do it.

Our convention is to create dev, staging, and production branches in the
git repository following that use the same name.

For example the *xproject* family have the following capistrano stages
and branches in teh git repository:

* *xproject_dev*_
* *xproject_staging*_
* *xproject_production*_

In the code below *<stage>* I will assume that we are using the
*xproject* series of stages and branches.

If you don't already have a local branch of staging

    git branch  --track xproject_staging origin/xproject_staging


Switch to the staging branch and merge from xproject_dev

    git co xproject_staging
    git merge xproject_dev


Push your copy of the staging branch to the gihub repository:

    git push origin xproject_staging

Dump the production database to this file `db/production_data.sql` on
the production server,
download it to the local folder `db/production_data.sql`, the cleans up
the production db/ folder.

    cap xproject_production db:fetch_remote_db

Push the production database from the local `db/production_data.sql` to
the staging server, then import the data into the database on staging, then cleanup.

    cap xproject_staging db:push_remote_db

Run any migrations on the staging server:

    cap xproject_staging deploy:migrate

There may be rake tasks that need to be run to update or fix data in the
database.

These should have corresponding capistrano tasks.

Test the staging server:
[http://xproject.staging.concord.org/](http://xproject.staging.concord.org/)

If the authors confirm that there are no blockers then let people know
when the update will take place and perform these tasks on the production server.

## other Rake tasks:

* `rigse:make:investigations` This task simply finds all activities with no parent investigation, and
creates a new investigation for that activity. The created investigation
has the same name and description as the activity it contains.

# haml

We use haml for some templates, see:
[http://haml.hamptoncatlin.com](http://haml.hamptoncatlin.com)/

To install this plugin we followed this procedure:

1. `gem install --no-ri haml`
1. `haml --rails path/to/rigse_app`


## Rendering

### haml

We use haml for some templates, see:
[http://haml.hamptoncatlin.com](http://haml.hamptoncatlin.com)/

to install this plugin we followed this procedure:
1. `gem install --no-ri haml`
1. `haml --rails path/to/rigse_app`

### Rendering OTML

The sass template rites.otml.sass generates the css file: rites.otml.css
which is used for styling the xhtml content in
OTCompoundDoc elements.

The Java OTrunk system uses Java html editor kit for rendering xhtml and
implements a very limited version of CSS that is somewhere
between CSS1 and CSS2. You can find out more about this implementations
limitations here: [Java 1.5: Class
CSS](http://java.sun.com/j2se/1.5.0/docs/api/javax/swing/text/html/CSS.html)



## Installers

Building installers requires that you are running on a mac with a local
installation of [Bit Rock](http://bitrock.com/)
The rake tasks assume that bitrock is in the standard /Applications/
folder.
You can override this by setting an environment variable in your shell
which points to the correct path, eg:
`export BITROCK_INSTALLER=/path/to/bitrock.app`

### config/installer.yml

Every host should have its own config/installer.yml file. There is a
config/installer.sample.yml file which can help get you started.
The shortname field should be specific to that host. Because of
limitations in bitrock, the shortname can not use
spaces,dashes,underscore, &etc.
The jnlp_url should point to a jnlp url on the target host. When you
run the
`rake build:installer:build_all` or
`cap installer:create` tasks, the jnlp_url must be available.


### Installer Rake Tasks:

Most of the installer building happens via rake tasks defined in
lib/tasks/make_installers.rake. a complete list of tasks can
be gotten using: `rake -T installer`

Here are the two useful tasks:

    rake build:installer:build_all # build all installers
    rake build:installer:new_release # create a new release specification interactively

Assuming that your installer.yml file is correct, running
`rake build:installer:build_all` will take care of the rest.
Build_all will automatically clean up, recache jars, and bump version
numbers.

### Installer Capistrano Recipes

There are two cap recipes in config/deploy.rb which take care of
creating installers using remote hosts installer.yml files.
* `cap installer:copy_config` copies the local installer.yml to the
remote server. This would be useful if you ran new_release locally, and
then
wanted to copy those config settings to the remote server.
* `cap installer:create` creates the installers and updates the remote
installer.yml file, and deploys the installer images.


### Sample session for building installers:

#### boot strapping an unconfigured server:

In this session we are assuming that we are working with a host which
does not have a local installer.yml file.
First we create a new local release. The first rake tasks asks a bunch
of questions, which are answered from the point of view of the staging
server.

     rake build:installer:new_release
     cap staging installer:copy_config
     cap staging installer:create


After running `rake build:installer:new_release`we end up with the
following local installer file:

    shortname: RitesStaging
    version: "200912.00"
    jnlp_config: [http://rites-investigations.staging.concord.org/investigations/545.jnlp](http://rites-investigations.staging.concord.org/investigations/545.jnlp)


this file gets pushed up to staging. with
`cap staging installer:copy_config` we only have to do that the first
time we create an
installer on staging. We could just as easily edit config/installer.yml.

The `cap staging installer:create` handles incrementing the version
number, and pushing the new config files and installers onto staging.

#### creating a fresh installer for a host that has had installers
before:

    cap staging installer:create

not much to do.

## Authentication, Sessions, and Cookies

### User authentication with Devise

Devise is already setup. The routes are setup, along with the mailers
and observers.
Forgotten password comes setup, so you don't have to mess around setting
it up with every project.

Devise uses the *pepper* parameter within settings.yml to encrypt user
passwords. The *pepper* is
generated automatically when first setting up the app. It is also
generated if not existing or is
blank when updating the app using the command:

    ruby config/setup.rb -y -q  -t default

Devise is also setup to use user activation. Users which require
activation are sent emails
automatically.

_RESTful Authentication is no longer integrated with the project. It
has been replaced with Devise. _

## Uses the Database for Sessions

### Will Paginate

We use will_paginate in pretty much every project we use.

### Exception Notifier

You don't want your applications to crash and burn so Exception Notifier
is already installed to let
you know when everything goes to shit.

config/initializers/exception_notifier.rb does the setup. Currently it
reads
"admin_email" from config/settings.yml and use it as the destination
address.
The setup can be modified to include multiple email addresses.
See the homepage readme of exception notifier.

#### Bug

It seems rails 2.3.3 and 2.3.4 fails to deliver emails when someone
passes
multiple destination addresses as an array, which exception notifier
does.
config/initializers/fix_mailer_on_rails_2.3.4.rb fixes the problem.

The code is borrowed from [Dmitry
Polushkin](https://rails.lighthouseapp.com/projects/8994/tickets/2340-action-mailer-cant-deliver-mail-via-smtp-on-ruby-191)

## Databases

On OS X the mysql2 gem usually can't find the mysql client library that
it needs to run. The command below fixes that. It assumes your mysql is
installed in the default basedir of /usr/local/mysql/lib. And it assumes
you are using bundler.


    install_name_tool -change libmysqlclient.16.dylib /usr/local/mysql/lib/libmysqlclient.16.dylib \
      `bundle show mysql2`/lib/mysql2/mysql2.bundle

For newer versions of rvm and mysql2, you will see an error like this

    dlopen(/Users/scytacki/.rvm/gems/ruby-1.9.3-p545/extensions/x86_64-darwin-13/\
      1.9.1/mysql2-0.3.15/mysql2/mysql2.bundle, 9): Library not loaded: libmysqlclient.18.dylib
      Referenced from: /Users/scytacki/.rvm/gems/ruby-1.9.3-p545/extensions/x86_64-darwin-13/\
        1.9.1/mysql2-0.3.15/mysql2/mysql2.bundle
      Reason: image not found - /Users/scytacki/.rvm/gems/ruby-1.9.3-p545/extensions/x86_64-darwin-13/\
        1.9.1/mysql2-0.3.15/mysql2/mysql2.bundle

So then to fix a command like this is needed:

    install_name_tool -change libmysqlclient.18.dylib /usr/local/mysql/lib/libmysqlclient.18.dylib \
      /Users/scytacki/.rvm/gems/ruby-1.9.3-p545/extensions/x86_64-darwin-13/1.9.1/mysql2-0.3.15/mysql2/mysql2.bundle

## CSS

### Rails 3 Asset Pipeline

The portal uses the"Rails 3 Asset
Pipeline":[http://guides.rubyonrails.org/asset_pipeline.html](http://guides.rubyonrails.org/asset_pipeline.html)
stylesheets, images, javascript should all be placed in the app/assets/
directory structure.
theme specific assets should be placed in `app/assets/theme/themename/`.

You should read the Rails guide for more information about the asset
Pipeline.

themes_for_rails has been configured to play nice with the asset
pipeline. See the initializer:
`config/initializers/themes_for_rails.rb`

`cap deploy` should trigger the rake task assets:precompile to run.

You can also run locally by hand: `bundle exec rake assets:precompile`

The assets will be compiled to public/assets which should be ignored by
.gitignore

When running in development mode you do not need to pre-compile your
assets.

## Solr & Sunspot

[Sunspot](https://github.com/sunspot/sunspot/blob/master/README.md
) is being used to provide search capabilities.

In development mode you will need to create an index and start sunspot:

    bundle exec rake sunspot:solr:start
    bundle exec rake sunspot:reindex

You can then visit the web interface to the solar server by visiting [localhost:8982/solr/admin/](http://localhost:8982/solr/admin/). Though I haven't found any good reason to do so.

### Rspec testing with sunspot disabled & enabled:

For rspec tests see the helper methods defined in spec/support/solr_spec_helper.rb

For cucumber tests, you can use "Given The materials have been indexed" to update solr indexes after fixture data has been loaded.


[https://github.com/sunspot/sunspot/wiki/RSpec-and-Sunspot](https://github.com/sunspot/sunspot/wiki/RSpec-and-Sunspot)

### Solr delpoyment and index-updating ###

If you make changes to how Solr does its indexing, you will have to run a cap task to tell it to reindex:

In theory a simple `bundle exec cap <host> solr:reindex` should work, but
to be sure use: `bundle exec cap <host> solr:hard_reindex` to restart and reindex.

## Application Settings & Settings YAML

There is a settings.yml file that contains site-wide stuff. The site
name, url and admin email are all used
in the Devise mailers, so you don't need to worry about editing them.

### Database YAML

## Enabling features via environment variables

Certain features of the portal are controlled via environment variables.

The `PORTAL_FEATURES` environment variable can take a string of the form "feature1 feature2" to
include the following features:

* `geniverse_remote_auth`: Remote authentication
* `allow_cors`: Allow CORS requests (see below)
* `genigames_data`: Genigames-related student sata saving
* `geniverse_wordpress`: Geniverse-related Wordpress connection

If CORS is enable, by default it will allow any request from '*.concord.org', to any route, but can
be controlled by two additional environment variables:

* `CORS_ORIGINS="x.example.com y.z.example.org"`: Sets the allowed CORS origins to a specific whitelist
* `CORS_RESOURCES="/xyz"`: Sets the allowed CORS resources to a specific route


## Technical debt.

Here is a brief list of things which need to be looked into:

* the embeddables should be dryed up with some mixin / super class.
* not all embeddables are using send_update_events, which is causing
stale pages.
* ocassionally browser rendering gets wonky and raw html and or
javascript get displayed in the page.
* transition to unobtrusive JS.
* send_update_events *might* not do what we want it to do, tests
should be written for it.


## Misc

* password and password_confirmation are set up to be filtered
* there is a default application layout file
* a page title helper has been added
* index.html is already deleted
* rails.png is already deleted
* a few changes have been made to the default views
* a default css file with blank selectors for common rails elements


## Copy & Paste Guide:

    git clone git@github.com:concord-consortium/rigse.git ./xproject
    cd xproject
    echo 'rvm use 1.8.7@xproject-portal --create' > .rvmrc;
    cd ..
    cd xproject

    gem install bundler
    bundle install

    ruby config/setup.rb -n "Cross Project Portal"  -D xproject -u <dbuser> -p <password> -t xproject  --states none -y -q  -f

    RAILS_ENV=production rake db:create:all
    RAILS_ENV=production rake db:migrate:reset
    RAILS_ENV=production rake app:setup:new_app

    rake db:test:prepare
    rake db:dump
    ruby script/server -e production
(end)


## License

CC Rails Portal is released under the [MIT License](LICENSE).
