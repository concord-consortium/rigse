# Upgrade Steps

This documents the steps taken to upgrade Portal from ruby 2.2.6/rails 3.2.22 to the latest ruby/rails version along with any of the issues found along the way.  This should be a good resource for other project upgrades.

## Steps Todo:

* Rails 4 upgrade

## Steps Done:

* Upgrade Rails to 3.2.22.19
  * run `bundle update rails --patch` inside docker container to get to latest patch version
  * Test it on travis
* Upgrade Ruby version file to to 2.3.7
* Update Docker image (docker-rails-base-private)

## How to update the Base Docker image

Note: The Private Dockerhub repo named `docker-rails-base-private` Dockerfile is stored at
the Concord github repo named `docker-rails-base`

1. Check out the Concord Base image repo `git@github.com:concord-consortium/docker-rails-base.git`
2. Switch to the `ruby23` branch.
3. edit the Dockerfile
4. Build the docker image: `docker build . -t concordconsortium/docker-rails-base-private:<new-tag-here> --build-arg RAILS_LTS_PASS=<replace-with-password>`  `new-tag` is of the format `ruby-x.x.x-rails-x.x.x.xx` resulting in tag names like:
`concordconsortium/docker-rails-base-private:ruby-2.3.7-rails-3.2.22.19`
5. Push the build to dockerhub: `docker push concordconsortium/docker-rails-base-private:<new-tag-here>`


## Dependency Versions

| |gem                      |Environment|Latest  |Latest Ruby|Initial 3|Final 3  |
|-|-------------------------|-----------|--------|-----------|---------|---------|




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