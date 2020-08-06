# Upgrade Steps

This documents the steps taken to upgrade Portal from ruby 2.2.6/rails 3.2.22 to the latest ruby/rails version along with any of the issues found along the way.  This should be a good resource for other project upgrades.

# Notes

* Current Bundler version 1.16.6
* Ensure that `bundle clean` is run before any `bundle upgrade`.
* bundler will not update top level dependencies that are transitive dependencies of other top level dependencies unless you add the transitive dependencies like `bundle update <gem1> <trans-dep-of-gem1>`.  Also may need to unpin the top level transitive dependencies to get them to resolve.
* bundler will not update transitive dependencies if they are already pinned in the lock file.  You can manually update transitive dependencies using `bundle update <trans-dep>`.

## Steps Todo:
* Rails 4 upgrade
    * Using the [guide](https://bit.ly/2XyACpP) start trying steps and generating issues
      * PATCH: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#http-patch
      * Gemfile: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0-gemfile
      * Active Record: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0-active-record
      * Active Resource: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#active-resource
      * Active Model: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#active-model
      * Action Pack: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#action-pack
      * Active Support: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#active-support
      * Helpers Loading Order: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#helpers-loading-order
      * Active Record Observer and Action Controller Sweeper: Active Record Observer and Action Controller Sweeper
      * sprockets-rails: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#sprockets-rails
      * sass-rails: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#sass-rails
    * Had to upgrade Devise from 2 to 3 due to rails dependency change which caused a lot of issues due to how tokens are generated and stored in version 3.  I was able to pin to Devise 3.1 which reduced the amount of code change needed.
      * [update devise config](https://bit.ly/2BZCeRJ) [and here](https://bit.ly/33scyZq)
    * Update rails from 4.0 to 4.1 (see [guide](https://bit.ly/2XyqFIK) )
    * Update rails from 4.1 to 4.2 (see [guide](https://bit.ly/2XtGXTa) )
      * Need to switch back to railslts
    * Update to ruby 2.4.5
    * Remove all gem versions for gems that haven't done a major upgrade except rails (keep at 3.2.22.5) to see what versions bundler picks (update: had to pin a bunch of gems so they wouldn't upgrade to ruby 2 versions)
      * Punted on this for now: gist of Gemfile. https://gist.github.com/knowuh/5b4619c3a16027e068264e996b56e80b

## Steps Done:
* Upgrade Rails to 3.2.22.19
  * run `bundle update rails --patch` inside docker container to get to latest patch version
  * Test it on travis
* Upgrade Ruby version file to to 2.3.7
* Update Docker image (docker-rails-base-private)
* Audit Dependencies. Make a table of gem versions, rm or comment out development gems.
* Rails 4 upgrade (see the [Guide](https://bit.ly/2XyACpP) )
    * Removed rails 2.3 style vendor/plugins (https://weblog.rubyonrails.org/2012/1/4/rails-3-2-0-rc2-has-been-released/)
      * rm rails/app/assets/javascripts/jquery.serialize-object.js
    * Looked for Gems to remove
    * `bundle clean` and `bundle install` and run rspec
    * Upgrade rails gem to 4.0.13 using `gem 'rails', '4.0.13'`
      * Cannot do this using railslts as they don't support 4.0. We will use the main gem repo until we get to 4.2 and then switch back to rails lts
      * During 4.0.0 change the following gem dependency issues were found
        * calpicker, depends on rails (~> 3.2.0), updated dependency here: https://github.com/concord-consortium/calpicker/pull/2
        * cc_portal_wordpress_integration, depends on rails (~> 3.2.11)
        * cc_portal_remote_auth, depends on rails (~> 3.2.11)
        * geniverse_portal_integration, depends on rails (~> 3.2.11)
        * genigames_connector, depends on rails (~> 3.2.11)
        * activerecord-import, depends on activerecord (~> 3.0) pinned to 0.28.2
        * devise, from 3 to 4
        * strong_parameters removed
        * change turbo-sprockets-rails3 to turbo-sprockets-rails4
        * unpinned development deps
      * Final update command: `bundle update devise rails sass-rails paperclip compass-rails`
      * Ran rspec tests to see issues
    * Resolved rspec startup issues with gem dependencies
      * compass was expecting an older version of sass, had to update both
      * unpinned `tinymce-rails` and did `bundle update tinymce-rails`

## How to update the Base Docker image

Note: The Private Dockerhub repo named `docker-rails-base-private` Dockerfile is stored at
the Concord github repo named `docker-rails-base`

1. Check out the Concord Base image repo `git@github.com:concord-consortium/docker-rails-base.git`
2. Switch to the `ruby23` branch.
3. edit the Dockerfile
4. Build the docker image: `docker build . -t concordconsortium/docker-rails-base-private:<new-tag-here> --build-arg RAILS_LTS_PASS=<replace-with-password>`  `new-tag` is of the format `ruby-x.x.x-rails-x.x.x.xx` resulting in tag names like:
`concordconsortium/docker-rails-base-private:ruby-2.3.7-rails-3.2.22.19`
5. Push the build to dockerhub: `docker push concordconsortium/docker-rails-base-private:<new-tag-here>`



## Note about ruby versions supported

Prior to 9th April 2019, stable branches of Rails since 3.0 use travis-ci for automated testing, and the list of tested ruby versions, by rails branch, is:

### Rails 4.0

- 1.9.3
- 2.0.0
- 2.1
- 2.2

### Rails 4.1

- 1.9.3
- 2.0.0
- 2.1
- 2.2.4
- 2.3.0

### Rails 4.2

- 1.9.3
- 2.0.0-p648
- 2.1.10
- 2.2.10
- 2.3.8
- 2.4.5

### Rails 5.0

- 2.2.10
- 2.3.8
- 2.4.5

### Rails 5.1

- 2.2.10
- 2.3.7
- 2.4.4
- 2.5.1

### Rails 5.2

- 2.2.10
- 2.3.7
- 2.4.4
- 2.5.1

### Rails 6.0

- 2.5.3
- 2.6.0
