CC Rails Portal Activity Authoring, Deployment, and Reporting System
====================================================================
[![Code Climate](https://codeclimate.com/github/concord-consortium/rigse.png)](https://codeclimate.com/github/concord-consortium/rigse)

Setup
-----

### Prerequisites

Working git, ruby, and rubygems, wget

#### Core Extensions

-   [Extensions to core classes applied at application
    startup](docs/core-extensions.textile)

#### Simple Getting Started

##### Using Docker

Install Docker and make sure that docker-compose is installed too (it should be part of the standard Docker installation).

    git clone git@github.com:concord-consortium/rigse.git portal
    cd portal
    docker-compose up # this will take 15 minutes to download gems

Increase memory available to Docker to 4GiB-5GiB (OSX: Preferences... -> Advanced tab).

Now open your browser to [http://0.0.0.0:3000](http://0.0.0.0:3000). On OS X this might
take more than 5 minutes to load the first page. Look in the terminal where you ran
`docker-compose up` to monitor progress.

Visit [the Docker docs](docs/docker.md) for how to use your portal running in docker. This
also includes: instructions on speeding things up on OS X, using a local dns+proxy system
to avoid port conflicts, and setting up ssh for capistrano deploys.

#### Tests

After getting the server running it's good to confirm that all the tests
pass before changing any code.

Prepare a database for use when running the spec tests:

    RAILS_ENV=test rake db:create
    rake db:test:prepare
    rake db:feature_test:prepare
    RAILS_ENV=cucumber rake app:setup:create_default_data

Start SOLR in test environment (it works with cucumber tests too):

    RAILS_ENV=test rake sunspot:solr:run

Run the rspec unit tests:

    rspec spec/

Prepare a database for use when running the cucumber tests:

    RAILS_ENV=feature_test rake db:create
    rake db:feature_test:prepare
    RAILS_ENV=cucumber rake app:setup:create_default_data

Run the cucumber integration tests:

    cucumber features/

All these tests should pass. If you add features make sure and add tests
for these new features.

#### SSO Clients and LARA (authoring) integration

These instructions assume that you are setting up LARA and Portal using
docker-compose files. It also assumes some prerequisites:
- You are using an http-proxy dns container: [Setup Dinghy on OSX](https://github.com/concord-consortium/lara/blob/master/README.md#setup-dinghy-on-os-x)
- You are using https for LARA and the Portal: [Setup https for LARA and Portal](https://github.com/concord-consortium/lara/blob/master/README.md#enabling-ssl-for-dinghy-reverse-proxy-on-os-x)
- You are logged into docker to gain access to our private images: [Logging into Docker](https://github.com/concord-consortium/lara/blob/master/README.md#getting-started)

With the following settings you can:
- Log into LARA from the portal
- Publish LARA activities and sequences to the portal
- Publish Activity Player activities and sequences to the portal
- Copy LARA activities and sequences from the portal
- View a teacher or student report (portal-report) for a local LARA activity or sequence
- View a teacher or student report (portal-report) for a local Activity Player activity or sequence

**Note:** Student data and resource structure will be stored in the hosted Firestore database of report-service-dev. This is a used by the portal-report. Because of this, you must be online.

##### Starting from scratch on a Mac

1. in the Portal: `cp .env-osx-sample .env`
2. in the Portal `.env` set `PORTAL_PROTOCOL=https`
3. start up the Portal: `docker-compose up`
4. Add a Firebase App for report-service-dev with `docker-compose exec app bundle exec app:setup:add_report_service_firebase_app`, it will ask for the "private_key", paste in the private key from report-service-dev firebase app in learn.staging.concord.org
5. in LARA: `cp .env-osx-sample .env`
6. in LARA `.env`:
    1. set `REPORT_SERVICE_TOKEN` (see the comment in the .env-osx-sample file)
    2. set `LARA_PROTOCOL=https`
    3. set `PORTAL_PROTOCOL=https`
7. start up LARA: `docker-compose up`
8. Setup admin access to LARA using a portal SSO login:
    1. Go to https://app.lara.docker
    2. Click log in, and choose "localhost"
    3. This will take you to the portal (app.portal.docker)
    4. Log in with `admin`, `password`
    5. You are now logged in with admin@concord.org in LARA, however this user is not actually an admin in LARA
    6. Run the following command in terminal in the LARA folder: `docker-compose exec app bundle exec rake lightweight:admin_last_user`

Notes:
- LARA runtime activities published to the portal will automatically have report buttons for teachers and students
- AP runtime activities published to the portal will not have report buttons for teachers and students. You must add
  external reports in the "portal settings" of the portal for the newly published resource
- The "show my work" button in the AP will not work by default when running locally like this. It will not
  add a correct sourceKey parameter for the portal-report URL it generates. Hopefully this will be fixed soon.
- The portal will not be configured with the same settings as learn.concord.org for the home page.
  To see this locally you should look at the settings on learn.staging.concord.org and copy those settings
  to your local portal settings.

##### Updating an existing setup

1. In the **Portal**, edit `.env`:
    1. Append `docker/dev/docker-compose-lara-proxy.yml` to the `COMPOSE_FILE` var.
    2. If your local portal domain is not `app.portal.docker`, then set `PORTAL_HOST`
    3. set `PORTAL_PROTOCOL=https`
    4. If your lara host name is not app.lara.docker, then set `LARA_HOST`
2. Stop your portal services if they are running, and update them with `docker-compose up`
3. In the Portal, as an administrator:
    1. Create or update an "Auth Client". Using the following settings:
        ```
        Name: 'localhost'
        App Id: 'localhost'
        App Secret: 'unsecure local secret'
        Client Type: confidential
        Site Url: 'https://app.lara.docker'
        Allowed Domains: (leave blank)
        Allowed URL Redirects: 'https://app.lara.docker/users/auth/cc_portal_localhost/callback'
        ```
    2. Check the external report called `DEFAULT_REPORT_SERVICE`. It should have a URL of: https://portal-report.concord.org/branch/master/index.html?sourceKey=app.lara.docker.username **Replace `username` with the username on your local system. If you don't know your username, run `echo $USER`**. Note: this sourceKey param needs to match the value of LARA's REPORT_SERVICE_TOOL_ID environment variable. And by default this variable is configured to be `app.lara.docker.${USER}`.
    3. Add a Firebase App for report-service-dev, copy the values for the report-service-dev firebase app in learn.staging.concord.org
    4. Add a new "Auth Client" for the portal-report
        ```
        Name: 'Portal Report SPA'
        App Id: 'portal-report'
        App Secret: (leave default value, this isn't used)
        Client Type: public
        Site Url: 'https://portal-report.concord.org'
        Allowed Domains: 'portal-report.concord.org'
        Allowed URL Redirects: 'https://portal-report.concord.org/branch/master/index.html'
        ```
4. In **LARA**, edit `.env`:
    1. Append `docker/dev/docker-compose-portal-proxy.yml` to the `COMPOSE_FILE` var.
    2. Set `PORTAL_HOST` to `app.portal.docker` or whatever domain your local portal is
    3. Set `PORTAL_PROTOCOL=https`
    4. set `LARA_PROTOCOL=https`
    5. Set `REPORT_SERVICE_TOKEN` (see the comment in the .env file)
    6. set `REPORT_SERVICE_URL` (see the value in the .env-osx-sample file)
5. Stop your Lara services if they are running, and update them with `docker-compose up`
6. If you want admin access to Lara when signing in with a portal user, you will need to first login to LARA
with this portal user. And then either:
    - use the rails console in LARA to set the `is_admin` flag of the newly created user.
    - use an existing admin in LARA to make the new user an admin.
7. Setup Activity Player support
    1. Add a Tool to the portal with:
        ```
        Name: ActivityPlayer
        Source Type: ActivityPlayer
        Tool ID: https://activity-player.concord.org
        ```
    2. Make an external report. In the Url field below replace the `username` in the sourceKey parameter with your local username:
        ```
        Name: AP Report
        Url: https://portal-report.concord.org/branch/master/index.html?sourceKey=app.lara.docker.username&answersSourceKey=activity-player.concord.org
        Launch text: AP Report
        Client: DEFAULT_REPORT_SERVICE_CLIENT
        Report Type: offering
        Allowed For Students: true
        Default Report For Source Type:
        Report available for individual students: true
        Report available for individual activities: true
        Use Query JWT: false
        Move Students API URL:
        Move Students API Token:
        ```
    3. Add this AP Report external report to each AP resource you publish the portal from LARA.

##### Troubleshooting

When you run the portal-report if you just see a spinner. Here are some steps to try:
1. Verify the source is be added to firestore:
    1. Go to the firebase console and open the report-service-dev firestore.
    2. Look in the sources collection
    3. You should see a `app.lara.docker.{$USER}` collection (USER is your local username)
    4. If you don't see this collection then your LARA is not properly publishing the report structure to the report-service. In LARA check the values of `REPORT_SERVICE_TOKEN` and `REPORT_SERVICE_URL` (see above). A less common error would be a misconfigured `LARA_HOST` and `TOOL_ID` setup.
    5. After fixing these values update your lara app so it picks up the variables with `docker-compose up`. And make a change to your activity so it republishes the structure to Firestore. Check that the `app.lara.docker.{$USER}` collection is there now.
2. Verify the resource structure added to firestore has the right URL:
    1. Go to the firebase console and open the report-service-dev firestore.
    2. Inside of the `sources/app.lara.docker.{$USER}` collection will be a `resources` collection. Inside of this will be a document for each activity or sequence that you've published from LARA.
    3. In these documents look at the `url` field. It needs to exactly matches what the portal-report is looking for. If it starts with `http:` instead of `https:` then you will see the spinner.
    4. To know what the portal-report is looking for in firestore: when you run the portal-report look at the network dev tools and look for the offering info request it makes to the portal. This request's url will look something like: `https://app.rigse.docker/api/v1/offerings/[id]`.  Look at the response to this request and find the `activity_url` field.
        - if this is an LARA runtime activity or sequence the activity_url will look like: https://app.lara.docker/activities/22
    In this case, this string should exactly match what is in the `url` field in firestore.
        - if this is a AP runtime activity the activity_url will look like: https://activity-player.concord.org/branch/master/?activity=https%3A%2F%2Fapp.lara.docker%2Fapi%2Fv1%2Factivities%2F22.json
        In this case, you need to unescape the activity parameter. Then take the value of the activity param and remove the `/api/v1` and remove the `.json` at the end. The result of that transformation snould exactly match what is in `url` field in firestore.
        - if this is a AP runtime sequence follow the directions for AP activity above except the parameter name is `sequence` instead of `activity`
    5. To fix the `http:` instead of `https:` problem make sure your `LARA_PROTOCOL` is set to `https` in your lara `.env` file. Then update your lara container with `docker-compose up`. And then make a change to the LARA activity or sequence to republish it. Verify the `url` field in firestore has been updated.

#### Virtual host settings (currently used for automation)
If you want to change the portal url from "app.portal.docker" to "learn.dev.docker", please follow the below steps:
1. In the Portal, edit '.env' file and update PORTAL_HOST as learn.dev.docker
2. In the Portal, edit '.env' file and update PORTAL_PROTOCOL as https for automation
3. In the Portal, as an administrator, edit the Auth Client settings:
```
    Site Url: 'https://learn.dev.docker'
    Allowed URL Redirects: 'https://learn.dev.docker/users/auth/cc_portal_localhost/callback'
```

#### GitHub Codespaces

Github Codespaces is a cloud-based development environment. We are currently using it to do development work on LARA and
Portal since it’s proven difficult to do local development on those codebases on M1 MacBooks.

Github’s documentation for Codespaces can be found at [here](docs.github.com/en/codespaces).

You will need to set up separate codespaces for LARA and the Portal.

Use of Codespaces incurs an hourly cost. The amount is not a lot, but it should be kept in mind. Codespaces will shut themselves down
automatically after a period of inactivity, but it would be best to manually shut them down when you’re done working in order to
minimize cost.

You can use Codespaces in web browser or you can connect to selected machine from desktop Visual Studio Code if you
install a Codespaces extension.

##### Basic setup

- Your GitHub account needs to have Codespaces activated by the organization admin.
- Go to the github.com page for the repository you will be working on.
- Click on the Code button, then click the Codespaces tab, and then click the “Create codespace on master” button.
- Portal requires 4-core machine because of memory (MySQL server tends to fail randomly on 2-core variant)

Once machine is up and running, most of the steps described for local development are still valid for GH Codespaces.
The main difference is that you should copy `.env-gh-codespaces-sample` to `.env` (instead of `.env-osx-sample`),
there's no need for Dinghy setup, and LARA and Portal hosts will be significantly different. However, everything
you need to do in practice is described below.

1. Run:
    ```
      cp .env-gh-codespaces-sample .env
    ```

2. Open LARA GitHub Codespace, run `echo ${CODESPACE_NAME}` in terminal, and set `LARA_CODESPACE_NAME` variable
in Portal's `.env` file.

3. Run
    ```
      docker login
      docker-compose up
    ```

4.  Once the app has started, open "Ports" tab in Visual Studio Code. Find a process that uses port 3000 and change its
visibility to public (right click on "Private" -> Port Visibility -> Public). You should see an updated address in
"Local Address" column. You can open this URL in the web browser and Portal should load. It seems it's necessary to do it
each time you run `docker-compose up`.

5. Open Portal, login as `admin` (password: `password`), and go to Admin tab.

    Go to Firebase Apps and create two new apps:
      - report-service-dev
      - token-service

    Client emails and private keys can be copied from learn.staging.concord.org.

Now, your Portal instance should work with LARA, Activity Player and basic reports.

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

    # finally change the theme setting in your config/settings.yml
    open config/settings.yml

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

#### Cucumber / Capybara

Feature specs that require javascript are run by Chrome via Selenium. By default Chrome will run in headless mode and there is nothing special you need to do inside of a Docker development environment.

However, if you would like to run Chrome in **non-headless mode** on your host machine, this is possible by making the following changes:

* set the environment variable `HEADLESS=false` if you are running the tests by using `docker-compose exec app /bin/bash`, then you can set HEADLESS in the shell.
* expose the capybara port by adding the docker-compose-publish-capybara-port overlay to to your .env file
* install `chromedriver` on your host machine
* start it with the command: `chromedriver --whitelisted-ips`
* ensure you have no firewall running on your host machine, or if you do please open port `9515`
* ensure that Chrome is installed on the host machine.

#### Factory Bot

> factory_bot allows you to quickly define prototypes for each of
your models and ask for instances with properties that are important to
the test at hand.

* [Factory Bot](http://thoughtbot.com/projects/factory_bot)
 * [Factory Bot repo](http://github.com/thoughtbot/factory_bot)
 * [Factory Bot
introduction](http://robots.thoughtbot.com/post/159807023/waiting-for-a-factory-bot)
* [Factory Botrdoc](http://rdoc.info/projects/thoughtbot/factory_bot)

### Running the rspec tests

**Running all the rspec tests:**

    bundle exec rake spec

**Running a single file:**

    bundle exec rake spec SPEC=spec/routing/dataservice/bundle_contents_routing_spec.rb

**Running a single directory:**

    bundle exec rake spec SPEC=spec/routing/dataservice

**Running all the controller tests:**

    bundle exec rake spec SPEC=spec/controllers

### Running the feature tests with cucumber

**Running all the feature tests:**
    bundle exec rake cucumber

**Running all the feature tests using the ci_reporter gem that's used
on the hudson CI system:**
    bundle exec rake hudson:cucumber

**Running a single feature:**

    bundle exec cucumber features/student_can_not_see_deactivated_offerings.feature

**Running a single feature in non-headless mode:**

    HEADLESS=false bundle exec cucumber features/student_can_not_see_deactivated_offerings.feature

### Using binding.pry with Cucumber tests

##### Problem:
Integration tests are difficult to debug without accessing the content in the browser and inspecting the relevant elements. Using debugging tools in the command line or trying to view the problem from a screenshot is not helpful when the problem might be a hidden link or different element type, for example.

##### Solution:
Using `pry` in non-headless mode in Chrome opens a new Chrome window showing you the state of the page where `pry` has paused the test. You can inspect elements in the page at that point in time to more easily identify the problem.

##### How to use:
Follow the instructions above to set up and start chromedriver.

For a particular cucumber test where JavaScript is enabled, find the step you want to test:

    And I follow "Admin"

Find the corresponding step definition and insert `binding.pry`:

    When /^(?:|I )follow "([^"]*)"$/ do |link|
      binding.pry
      first(:link, link).click
    end

Make sure chromedriver is running and run the test with HEADLESS=false prepended to the path

    $ HEADLESS=false bundle exec cucumber features/admin_accesses_special_pages.feature

When `pry` is hit, a new Chrome window will pop up where you can inspect element and use the pry in the command line as usual.


*note: Please see documentation regarding running `chromedriver` on your host machine above ☝️.*

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

- [Capistrano Deployment Recipes](docs/cap-tasks.md)


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

## Authentication, Sessions, and Cookies

### User authentication with Devise

Devise is already setup. The routes are setup, along with the mailers
and observers.
Forgotten password comes setup, so you don't have to mess around setting
it up with every project.

Devise uses the *pepper* parameter within settings.yml to encrypt user
passwords. A default *pepper* is provided in settings.samles.yml
You need to change this when deploying to a public server.

Devise is also setup to use user activation. Users which require
activation are sent emails
automatically.

### Single Sign On

The app supports user registration and authentication via third party single sign using OAuth. Using this feature requires setting up OAuth credentials with the third party.

The app currently supports OAuth registration and authentication using Google and Schoology.

To set up single sign on with Google, follow the steps below.

1) Create a new Google app in console.developers.google.com.

2) Create a set of OAuth credentials for the app. For the "Authorized JS origin" value use the valid public domain that resolves to your copy of the app on the web. For the "Authorized redirect URI" value use `https://[your domain]/users/auth/google/callback`.

3) Take the Client ID and Client Secret values created in step two and add them as values for GOOGLE_CLIENT_KEY (Client ID) and GOOGLE_CLIENT_SECRET (Client Secret) in your app's .env file.

4) Restart the app.

#### Testing Single Sign On with Google and a Local Portal

Create a set of OAuth credentials for the app following the steps above, but for the "Authorized JS origin" value use a valid public top level domain that resolves to 127.0.0.1. Google won't accept 127.0.0.1 or a domain like app.portaldocker.local. An easy option is to use `https://lvh.me` which resolves to 127.0.0.1 without requiring any special configuration of your computer.

For the "Authorized redirect URI" value use `https://[your domain]:[your port number]/users/auth/google/callback`. If, for example, you use lvh.me and Docker is serving your portal over port 32789, the value would be `https://lvh.me:32789/users/auth/google/callback`.

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


You will need to create solr cores if you want to update materials or publish.
At the least you will need a 'development' solr core.  Here is a basic set of directions:

1. Make sure there are no solr processes running with `ps auxxwww | grep solr`
2. `scp -r deploy@learn.staging.concord.org:/web/portal/shared/solr-template solr`
3. `cp -r ./solr/production ./solr/development`
4. `vim ./solr/development/core.properties` (change name from production to development)
5. `bundle exec rake sunspot:solr:start`
6. `bundle exec rake sunspot:solr:reindex` (edited)

You could also create a test core by repeating steps 3 & 4.

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

* `allow_cors`: Allow CORS requests (see below)

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

## Archiving a portal

A set of rake tasks is available under the ```archive_portal``` namespace that enable the portal data to be archived.  These tasks are:

* archive_portal:extract_and_upload_images - extracts the image binary data from the database and uploads it to S3
* archive_portal:generate_teacher_reports - generates learner details reports for all teachers and uploads them to S3
* archive_portal:generate_runnable_reports - generates learner details reports for all runnables and uploads them to S3

The rake tasks use a config file at /config/archive_portal.yml to specify the S3 bucket parameters to use when extracting images and to use when generating the url to those images in the reports.
A /config/archive_portal.sample.yml file exists to be copied and updated with real values.

These tasks will take a long time. Easiest way to run them is to ssh to running server and run them in the background
using nohup, e.g.:

`nohup bundle exec rake archive_portal:extract_and_upload_images &`

You can close your ssh session and the task will be still running. Logs will be saved in `nohup.out`.
## New Admin interfaces

As of 2020-06-12 we are in the process of moving some administrative functions to a new technology stack.
See the [New Admin interface documentation](docs/admin-interface.md)

## License

CC Rails Portal is released under the [MIT License](LICENSE).
