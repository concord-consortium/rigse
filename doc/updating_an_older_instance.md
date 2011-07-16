## Updating an older portal instance to master

This documentation shows details for how an older branch of the code (xproject-dev)nwas updated to master and deployed.

I'm going to merge master with the xproject-dev branch and deploy to this dev site.
As part of that process I'll also pull the database into my local working environment.

Having yourself already registered as a user on the remote site makes informal testing easier.

I didn't have an account on http://xproject.dev.concord.org/ so I first registered as a member and then ssh'ed to otto added the 'admin'role to my account using script/console.

I cloned and setup a new instance of the rails-portal:

    git clone git@github.com:concord-consortium/rigse.git xproject-git
    cd xproject-git
    git submodule update --init


Setup the the yaml state files in config:

    ruby config/setup.rb -n xproject -u <mysql_user> -p <mysql_password> -t xproject -y -q -f

config/setup.rb has help output:

    $ ruby config/setup.rb --help
    Usage: config/setup.rb [@options]
        -t, --theme THEME                theme used to setup and run this Investigations instance, default: 'default'
        -n, --name APP_NAME              app name for this Investigations instance, default: 'Investigations'
        -u, --user USERNAME              database username, default: 'root'
        -p, --password PASSWORD          database password, default: 'password'
        -D, --database DATABASE          prefix to add to the names for the development, test, and production databases, default: 'xproject_git'
        -q, --quiet                      display fewer console messages, default: false
        -y, --yes                        automatically answer yes and accept defaults, default: #{default_answer_yes}
        -f, --force                      force updates of settings.yml and database.yml, default: false
        -h, --help                       show this help

Setup the databases:

    rake db:create:all

Create the schema so rake and cap tasks run properly (is this needed?):

    RAILS_ENV=production rake db:migrate:reset

Get a copy of the remote db and load it:

    cap xproject-dev db:fetch_remote_db
    rake db:load

Also get a copy of the site keys so the authentication salt matches the remote server so I can login using the same password:

  cap xproject-dev db:fetch_remote_site_keys

OK, now I've got the master branch but I just downloaded a db schema that was created by the program code a while ago. I need to know if there are updates to the data in the db that need to be applied.

Login to http://xproject.dev.concord.org/ as an admin and open the deploy link in the footer to see the github page with the commit that was last deployed. In this case it was by Charlie on June 25 2010.

    Changes for story 'Add Grade Selection field to 'adding a new class' window'
    https://github.com/concord-consortium/rigse/commit/c0b47dcccb405adca10b1800c35b4125fd322d64

And that commit is the tip of the xproject-dev branch

    $ git log -1 remotes/origin/xproject-dev
    commit c0b47dcccb405adca10b1800c35b4125fd322d64
    Author: Charlie H <cmhonig@gmail.com>
    Date:   Fri Jun 25 14:41:12 2010 -0400

        Changes for story 'Add Grade Selection field to 'adding a new class' window'

There have been migrations:

    $ git diff --stat remotes/origin/xproject-dev: db/migrate/
     .../20100630165146_create_dataservice_blobs.rb     |   19 +++++++++++
     ...1180427_add_original_body_to_bundle_contents.rb |    9 +++++
     ...0100702164051_create_saveable_image_question.rb |   34 ++++++++++++++++++++
     ...01025175546_create_report_embeddable_filters.rb |   14 ++++++++
     ..._add_ignore_flag_to_report_embeddable_filter.rb |    9 +++++

So apply them:

    rake db:migrate

It looks like there might have been new rake tasks to fixup issues in the database:

    $ git diff --stat remotes/origin/xproject-dev: lib/tasks
     lib/tasks/database.rake |    4 +-
     lib/tasks/fixups.rake   |   66 +++++++++++++++++++++++++++++++++++++++++++++++
     lib/tasks/jnlp.rake     |    4 +-
     3 files changed, 70 insertions(+), 4 deletions(-)

Take a closer look at the commits and changed file in lib/tasks since the last commit in xproject-dev:

    $ git log --stat --reverse c0b47dcc..  lib/tasks/
    commit f5ffa8298a28769448e8fe03c165a08bba5b8f16
    Author: Stephen Bannasch <stephen.bannasch@gmail.com>
    Date:   Tue Jul 20 10:48:22 2010 -0400

        rake db:load => wrap mysql password in single quotes
    
        I was errors running the following on the dev server:
    
          RAILS_ENV=production rake db:load
    
        The problem didn't show up my local dev instance.
    
        The mysql password used on the dev server had characters
        that the shell interpreted specially. Putting the password
        in single quotes when building the cmd string solved the problem.

     lib/tasks/database.rake |    2 +-
     1 files changed, 1 insertions(+), 1 deletions(-)

    commit bd44c713d76409e821639e4595579a53b2feace2
    Author: Aaron Unger <aunger@concord.org>
    Date:   Tue Jul 20 11:26:08 2010 -0400

        Fix another mysql password wrapping in single quotes.

     lib/tasks/database.rake |    2 +-
     1 files changed, 1 insertions(+), 1 deletions(-)

    commit eeec0d7bf76c0a348144b735c6b72ab5fdf37159
    Author: Noah Paessel <knowuh@gmail.com>
    Date:   Thu Aug 26 18:27:22 2010 -0400

        RAKE TASK: reset activity positions !!!
    
        run db:dump first incase things go badly.
    
        Probably should run the report first too (?)

     lib/tasks/fixups.rake |   66 +++++++++++++++++++++++++++++++++++++++++++++++++
     1 files changed, 66 insertions(+), 0 deletions(-)

    commit dc5c52b9c4e0eca886ec1149370fca74b925100f
    Author: Stephen Bannasch <stephen.bannasch@gmail.com>
    Date:   Wed Oct 20 14:13:45 2010 -0400

        erase cached maven_jnlp object when building new app

     lib/tasks/jnlp.rake |    4 ++--
     1 files changed, 2 insertions(+), 2 deletions(-)

Take a closer look at Noah's commit since he didn't document exactly how to run the rake task in the commit message:

    $ git show eeec0d7bf76c
    commit eeec0d7bf76c0a348144b735c6b72ab5fdf37159
    Author: Noah Paessel <knowuh@gmail.com>
    Date:   Thu Aug 26 18:27:22 2010 -0400

        RAKE TASK: reset activity positions !!!
    
        run db:dump first incase things go badly.
    
        Probably should run the report first too (?)

    diff --git a/lib/tasks/fixups.rake b/lib/tasks/fixups.rake
    index d3d8c76..076f2f4 100644
    --- a/lib/tasks/fixups.rake
    +++ b/lib/tasks/fixups.rake
    @@ -327,5 +327,71 @@ sensor or prediction graph_type so it sets the type to 1 (Sensor).
         end
 
       end
    +
    +  namespace :report do
    +    # NSP: 20100826
    +    desc "report on activities without position attributes"
    +    task :activity_positon_bug_report, :file_name, :needs => :environment do |t,args|
    +      args.with_defaults(:file_name => 'position_bug_activity_report.csv')
    +      file_name = args.file_name
    +      suspect_activities = Activity.find(:all, :conditions => "position is null and investigation_id is not null")
    +      good_activities =  Activity.find(:all, :conditions => "position is not null and investigation_id is not null")
    +      puts "#{suspect_activities.size} without positions & #{good_activities.size} with good positions" 
    +      bad_hash = suspect_activities.map do |a|
    +        {
    +          :id => a.id,
    +          :inv_id => a.investigation.id,
    +          :investigation => a.investigation.name,
    +          :act_size => a.investigation.activities.size,
    +          :z => "[ #{a.investigation.activities.map{ |iact| iact.id}.join(",")} ]",
    +          :published => (a.investigation.published? ? "public" : "draft"),
    +          :offerings => a.investigation.offerings.size,
    +          :updated => (a.updated_at.strftime("%F"))
    +        }
    +      end
    +      bad_hash = bad_hash.sort_by {|a| [a[:published], a[:inv_id], a[:id] ]}
    +      File.open(file_name,'w') do |file|
    +        bad_hash.each do |a|
    +          line = %/ "#{a[:investigation]}", "#{a[:published]}", "#{a[:act_size]}", "#{a[:updated]}", "#{a[:id]}", "#{a[:z]}"/
    +          file.puts(line)
    +        end
    +      end
    +      puts "report results should be in #{file_name}"
    +    end
    +  end
    +
    +  namespace :fixup do
    +    desc "reset all activity position information"
    +    task :reset_activity_positions => :environment do
    +      # We actually want to reset the position attribute on ALL activities
    +      all_invs = Investigation.all
    +      puts "fixing up #{all_invs.length} investigations"
    +      all_invs.sort_by { |inv| inv.id }.each do |inv|
    +        inv.reload # force the default ordering of activities
    +        act_order = inv.activities.map{ |a| a.id}.join(",")
    +        puts "working with #{inv.id} #{inv.name}"
    +        position = 1
    +        inv.activities.each do |act|
    +          if (act.position != position)
    +            puts "    fix: (#{act.position}) ==> (#{position})"
    +          end
    +          act.update_attributes!(:position => position)
    +          position = position + 1
    +        end
    +        inv.reload
    +        new_order = inv.activities.map{ |a| a.id}.join(",")
    +        raise "Non-matching activity order" unless (new_order == act_order)
    +        predicted_position = 1
    +        inv.activities.each do |act|
    +          raise "Activity has wrong position: #{act.position} != #{predicted_position}" unless (act.position == predicted_position)
    +          predicted_position = predicted_position + 1
    +        end
    +        puts "  reset position information for #{position - 1} activities in #{inv.name}:"
    +        puts "     PRE: #{act_order}"
    +        puts "    POST: #{new_order}"
    +        puts
    +      end
    +    end
    +  end
     end

Looks like there are two tasks that got added:

Reporting on a problem:

  rake rigse:report:activity_positon_bug_report
    report on activities without position attributes

And fixing a problem:

  rake rigse:fixup:reset_activity_positions
    reset all activity position information

So run: rake rigse:fixup:reset_activity_positions

Turns out that three activities were fixed.

When I make a commit like this I like to put the specific rake (and cap) tasks to run in the commit message. When the rake task is working correctly I usually also add the matching cap task for running the rake task remotely:

Which reminds me that I should also check what cap tasks have been added:

    $ git log --stat --reverse c0b47dcc..  config/deploy.rb
    commit 137cf5b686b2cd15c344881926ca139a60ca5415
    Author: Aaron Unger <aunger@concord.org>
    Date:   Fri Jul 23 13:24:19 2010 -0400

        Geniverse theme and deploy config.

     config/deploy.rb |    1 +
     1 files changed, 1 insertions(+), 0 deletions(-)

    commit 154b24821630fefa9fb0125e395f8543949d85f4
    Author: Stephen Bannasch <stephen.bannasch@gmail.com>
    Date:   Wed Oct 20 14:23:21 2010 -0400

        add cap task: convert:reset_activity_positions

     config/deploy.rb |    7 +++++++
     1 files changed, 7 insertions(+), 0 deletions(-)

    commit b4c72bbd25d98050f16f07ef91fb785a8c875150
    Author: Aaron Unger <aunger@concord.org>
    Date:   Wed Dec 29 10:55:24 2010 -0500

        Add initializer sample for setting a relative url root.

     config/deploy.rb |    2 ++
     1 files changed, 2 insertions(+), 0 deletions(-)

    commit 3b7ba5c189c5c6b2466da94b8e55b2f3e16134bd
    Author: Noah Paessel <knowuh@gmail.com>
    Date:   Fri Dec 3 09:44:26 2010 -0500

        Add support for newrelic rpm

     config/deploy.rb |    1 +
     1 files changed, 1 insertions(+), 0 deletions(-)

    commit 321c2836f5164025c4eb5294e03f78f4bddc55a1
    Author: Stephen Bannasch <stephen.bannasch@gmail.com>
    Date:   Mon Jan 10 12:10:27 2011 -0500

        commented out support for newrelic reporting in master
    
        This can be enabled per-project.

     config/deploy.rb |    3 ++-
     1 files changed, 2 insertions(+), 1 deletions(-)

Looks like I added the cap task on Oct 20 2010 that matches Noahs rake task from Aug 26.

Now I know that later when the external xproject-dev site is updated I'll need to also run:

    cap xproject-dev convert:reset_activity_positions

Maybe I'm ready to run tests ???

    $ rake spec

Quick crash!

    rubygems.rb:223:in `activate': You have a nil object when you didn't expect it! (NoMethodError)
    You might have expected an instance of Array.
    The error occurred while evaluating nil.map

It turns out rspec and rspec-rails needed to be updated.

I should also take a look at what might have changed here: config/environments

    $ git log --stat --reverse c0b47dcc..  config/environments

    commit 6478240852c371cfed3975abf3879aa7521ee0f4
    Author: Aaron Unger <aunger@concord.org>
    Date:   Thu Dec 30 18:06:03 2010 -0500

        Update rspec and rspec-rails versions so we don't accidentally pull in the rails3 rspec.

     config/environments/cucumber.rb |    6 +++---
     1 files changed, 3 insertions(+), 3 deletions(-)

    commit b950767fa7b606cc1ef4155d1bdf5521911dcd64
    Author: Matt Venables <mattv@cantinaconsulting.com>
    Date:   Mon Jan 3 14:16:58 2011 -0500

        Update rspec and rspec-rails versions for test environment to mimic changes in cucumber environment.

     config/environments/test.rb |    4 ++--
     1 files changed, 2 insertions(+), 2 deletions(-)

    commit ecb112b2f1625d7a2d23fe5256656c0b7fdbf3f5
    Author: Matt Venables <mattv@cantinaconsulting.com>
    Date:   Mon Jan 3 15:31:30 2011 -0500

        Require ci_reporter gem to be version 1.6.0

     config/environments/test.rb |    2 +-
     1 files changed, 1 insertions(+), 1 deletions(-)

    commit 16530fe58cdfb5c044a676df6185b857c7d4b492
    Author: Matt Venables <mattv@cantinaconsulting.com>
    Date:   Wed Jan 5 15:30:09 2011 -0500

        Force capybara version 0.3.9
    
        The cucumber_rails v0.3.2 gem does not support capybara 0.4.0, which is causing some of the tests to fail.  Hopefully this change will fix those.

     config/environments/cucumber.rb |    2 +-
     config/environments/test.rb     |    2 +-
     2 files changed, 2 insertions(+), 2 deletions(-)

    commit 8f0569bf0a7948add88150b24a5c79943de667b9
    Author: Matt Venables <mattv@cantinaconsulting.com>
    Date:   Wed Jan 5 15:53:52 2011 -0500

        Move back to capybara 0.3.8, cucumber-rails 0.3.1
    
        Attempting to fix an ElementNotFound bug in the tests that's only appearing on the CI server.  Believe it might have something to do with the javascript helpers with capybara/cucumber-rails

     config/environments/cucumber.rb |    4 ++--
     config/environments/test.rb     |    4 ++--
     2 files changed, 4 insertions(+), 4 deletions(-)

I still get a crash because the ci_reporter gem v 1.6.0 isn't installed -- that should probably be included in: config/environments/cucumber.rb -- or the code should be refactored so they both use the same set of gems specified in one place.

    $ rake spec
    (in /Users/stephen/dev/test/xproject-git)
    No server is running
    Running specs locally:
    loading test environment
    Missing these required gems:
      ci_reporter  = 1.6.0

Turns out that is only specified in config/environments/test.rb. I had a problem earlier running:

    $ RAILS_ENV=test rake gems:install

Which is why I instead ran:

    $ sudo RAILS_ENV=cucumber rake gems:install to install the rspec and rspec-rails gems but now it runs successfully installing the ci_reporter gem.

Now trying to run the spec tests reports that I need to run some migrations in the test db:

      *** pending migrations need to be applied to run the tests
      *** run: rake db:test:prepare

Normally the test db is empty of data when you start running tests and the setup methods for the tests prep the db.

The following migrations are run in the test db because the data they create are in effect treated as fixtures in both the test AND the production/dev databases. The probe-related ones are general. The ri_gse-related ones are only for the RITES project and should be refactored at some point so that these only run when setting up a specific RITES instance of the rails-portal.

    $ rake db:test:prepare
    (in /Users/stephen/dev/test/xproject-git)
    Executing rake task or running in test/cucumber env: skipping Admin::Project.create_or_update_default_project_from_settings_yml
    Problem processing key 'host' in config/mailer.yml
    undefined method `host=' for ActionMailer::Base:Class
    Started observers
    Loading probe_device_configs...
    Loading probe_data_filters...
    Loading probe_vendor_interfaces...
    Loading probe_physical_units...
    Loading probe_calibrations...
    Loading probe_probe_types...
    Loading ri_gse_assessment_targets...
    Loading ri_gse_big_ideas...
    Loading ri_gse_domains...
    Loading ri_gse_expectations...
    Loading ri_gse_expectation_indicators...
    Loading ri_gse_expectation_stems...
    Loading ri_gse_grade_span_expectations...
    Loading ri_gse_knowledge_statements...
    Loading ri_gse_unifying_themes...
    Loading ri_gse_assessment_target_unifying_themes...

Now the spec tests run -- but I notice there a noisy library outputting "calling replace_offensive_html" many times -- presumably this was in there for primitive debugging at some earlier point and just didn't get removed -- this could be easily fixed.

Rspec displays 13 deprecation warnings:

    DEPRECATION WARNING: you are using deprecated behaviour that will
    be removed from a future version of RSpec.

    ./spec/importers/rinet_data_spec.rb:33:in `be_in_nces_school'

    * simple_matcher is deprecated.
    * please use Matcher DSL (http://rspec.rubyforge.org/rspec/1.3.0/classes/Spec/Matchers.html) instead.

These would also probably be easy to fix and would not only make it easier upgrading later but would make the console output much less noisy.

    Finished in 515.916315 seconds

    1589 examples, 0 failures, 53 pending
    
The spec test take much longer to run than I'd like. I'd like to see this run faster. A possibly simple improvement that would pay larger benefits is getting this running on the latest stable release of Ruby 1.9.2. The tests would run faster and also the app itself.

Now try the cucumber tests:

    $ rake cucumber

These also pass but take a long time:

    65 scenarios (4 undefined, 6 pending, 55 passed)
    351 steps (20 skipped, 21 undefined, 6 pending, 304 passed)
    2m50.576s

OK now push the changes to github, deploy, run the migrations and the fix for activity position and restart the server instance.

    cap xproject-dev deploy

The very end of the deploy task includes these sudo operations we need to be changed so sudo isn;'t required:

      * executing "sudo -p 'sudo password: ' rm -rf /web/xproject.dev.concord.org/releases/20100621125936"
        servers: ["xproject.dev.concord.org"]
        [xproject.dev.concord.org] executing command
    Password: 
     ** [out :: xproject.dev.concord.org] 
        command finished
     ** transaction: commit
      * executing `deploy:restart'
        triggering before callbacks for `deploy:restart'
      * executing `deploy:set_permissions'
      * executing "sudo -p 'sudo password: ' chown -R apache.users /web/xproject.dev.concord.org"
        servers: ["xproject.dev.concord.org"]
        [xproject.dev.concord.org] executing command
        command finished
      * executing "sudo -p 'sudo password: ' chmod -R g+rw /web/xproject.dev.concord.org"
        servers: ["xproject.dev.concord.org"]
        [xproject.dev.concord.org] executing command
        command finished
      * executing "sudo -p 'sudo password: ' touch /web/xproject.dev.concord.org/current/tmp/restart.txt"
        servers: ["xproject.dev.concord.org"]
        [xproject.dev.concord.org] executing command

Finish running the necessary cap tasks:

    cap xproject-dev deploy:migrate
    cap xproject-dev convert:reset_activity_positions
    cap xproject-dev deploy:restart

Opening this page however definitely shows something is wrong: http://xproject.dev.concord.org/ -- the sidebar and banner are missing. 

However the "good" news is that I have the same problem running locally -- so if I fix it here and re-deploy it's likely to be fixed on the remote server also.

Sometime more complex problems arise here because there have been changes to the structure or content in config/settings.yml on the remote server.

If there are changes that should be made for every xproject site then changes should be made in config/themes/xproject/settings.sample.yml

Then run config/setup.rb on the remote instance specifying the xproject theme to re-write config/settings.yml.

If there is custom changes then backup config/settings.yml, re-generate it and manually merge back changes from the backup.
