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
The capistran-autoscaling gem will prevent you from doing an update unless your AWS keys are set.

*IMPORTANT:* Deploying to a load-balanced server will TERMINATE ec2 instances that are in the load balance group
that do not have a Name tag set.

If you do load balancing deployments, you should specify the deployment target host without using 
the load-balancers web domain name. For example, the deploy-to host for has-production is has.production.concord.org
and the load balancer responds to has.portal.concord.org.

As of October 30, 2014 the only servers which are should be using load-balancers in this way is has-production and has-staging.

  1. Read the documentation here: https://github.com/concord-consortium/capistrano-autoscaling/tree/concord
  2. setup the AMI source name.  This should be the Name (tag) of the EC2 instance you deploy to. It will be imaged after
  the deploy:restart task. That image will seed the launch-configuration for the auto-scaling group.
  3. export your credentials using something like this: 
  `export AWS_ACCESS_KEY_ID='xxxx'` and
  `export AWS_SECRET_ACCESS_KEY='xxxx'`


### Miscellaneous recipes

**Set the gse_key field for existing GradeSpanExpectations**
* `cap convert:set_gse_keys`

