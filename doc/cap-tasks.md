## Capistrano Deployment Recipies

More info on capistrano-ext/multistage deployments can be found here:
[http://weblog.jamisbuck.org/2007/7/23/capistrano-multistage](http://weblog.jamisbuck.org/2007/7/23/capistrano-multistage)

### Database recipes

There are a few database oriented recipes which should cover the basic
db-oriented tasks you might want to do.
Here are some scenarios and how to do them. Remember, all commands are
entered on your local machine, in the application root directory.

There are 4 basic commands:

* `rake db:dump`This dumps the current environment's database to db/… eg
db/production_data.sql or db/development_data.sql
* `rake db:load` This overwrites your current db with a sql dump from db/
into the current environment's db, provided a dump exists for your current environment
* `cap (production|staging|development) db:fetch_remote_db` The same as db:dump,
except it dumps the database from whichever remote instance you chose
* `cap (staging|development) db:push_remote_db` Same as db:load, except the remote database is overwritten

**Download the production database to use locally**

    cap production db:fetch_remote_db
    cp db/production_data.sql db/development_data.sql
    rake db:load


**Reset the Staging or Development database with Production's version**

    `cap production db:fetch_remote_db`
    `cap staging db:push_remote_db` or
    `cap development db:push_remote_db`

**Update Staging or Development with a copy of your local database**

    rake db:dump
    cap staging db:push_remote_db  # or
    cap developmentdb:push_remote_db

**Note**: For safety, you can't push a database to production. If you
accidentally try, you'll get a message saying you can't do that.

### EC2 load balancing Recipe using capistrano-autoscaling:

If you are going to deploy to a server with load balancing enabled (eg has-production), read deploy/has-production.rb

  1. Uncomment the auto-scale callback in config/deply/(server).rb or add one like this:
  `after "deploy:restart", "autoscaling:update"`
  2. Read the documentation here: https://github.com/concord-consortium/capistrano-autoscaling/tree/concord
  3. export your credentials using something like this: 
  `export AWS_ACCESS_KEY_ID='xxxx'` and
  `export AWS_SECRET_ACCESS_KEY='xxxx'`


### Miscellaneous recipes

**Set the gse_key field for existing GradeSpanExpectations**
* `cap convert:set_gse_keys`

