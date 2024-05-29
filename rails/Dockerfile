ARG NODE_VERSION=18.18.0
ARG RUBY_VERSION=2.7

FROM node:${NODE_VERSION}-alpine AS node
# Stick to Alpine <= 3.13 to avoid issues with ECS Docker
# See: https://github.com/docker-library/ruby/issues/351#issue-940462153
FROM docker.io/ruby:${RUBY_VERSION}-alpine3.12

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

RUN node -v

RUN true

RUN apk add \
  # The Ruby Gem "delayed-web" has a transitive depdency for "racc" which builds
  # native extensions and requires a C toolchain (it attempts to use gcc):
  # "Gem::Ext::BuildError: ERROR: Failed to build gem native extension."
  # "The compiler failed to generate an executable file. (RuntimeError)"
  # "You have to install development tools first."
  build-base \
  # The Ruby Gem "mimemagic" requires Freedesktop.org Shared MIME Info to be installed:
  # "Could not find MIME type database in the following locations:"
  # "Ensure you have either installed the shared-mime-info package for your distribution..."
  shared-mime-info \
  # The Ruby Gem "mysql2" requires a MySQL client library to link against
  # See: https://github.com/brianmario/mysql2#general-instructions
  mariadb-dev \
  # The "execjs" requires a supported JavaScript runtime to be installed
  # "/usr/local/bundle/gems/execjs-2.8.1/lib/execjs/runtimes.rb:58:in `autodetect':
  # Could not find a JavaScript runtime. See https://github.com/rails/execjs for a list of available runtimes.
  # (ExecJS::RuntimeUnavailable)"
  # See: https://github.com/rails/execjs#execjs
  nodejs \
  # "/usr/local/bundle/gems/tzinfo-2.0.4/lib/tzinfo/data_source.rb:159:in
  # `rescue in create_default_data_source': tzinfo-data is not present. Please add gem 'tzinfo-data'
  # to your Gemfile and run bundle install (TZInfo::DataSourceNotFound)"
  tzdata \
  # See: https://github.com/sstephenson/ruby-yui-compressor#label-Installing+and+loading+Ruby-YUI+Compressor
  openjdk8-jre

ENV APP_HOME /rigse/

RUN adduser -D -u 13000 app

RUN mkdir -v $APP_HOME
RUN chown app $APP_HOME
WORKDIR $APP_HOME

USER app

# Copy Gemfile and its lock file
COPY --chown=app ./Gemfile* $APP_HOME
# TODO: bundle config set without 'development test'
RUN bundle install --without development test
COPY --chown=app ./ $APP_HOME

RUN \
  cp ./config/database.sample.yml ./config/database.yml \
  && cp ./config/settings.sample.yml ./config/settings.yml \
  && cp ./docker/prod/config/mailer.yml ./config/ \
  && cp ./docker/prod/config/aws_s3.yml ./config/ \
  && cp ./config/app_environment_variables.sample.rb app_environment_variables.rb \
  && cp -r ./docker/prod/config/initializers/ ./config/

# Change to the react-components directory and run npm build BEFORE rails assets precompile
RUN cd react-components && npm install && npm run build && cd ..

# Set production
ENV RAILS_ENV=production
# compile the assets - NOTE: DOCKER_NO_INIT_ON_PRECOMPILE MUST be set to true for this to work
# otherwise somewhere in the initializers it tries to connect to the database which will fail
ENV DOCKER_NO_INIT_ON_PRECOMPILE=true
# Seems like the above doesn't work anymore: https://github.com/rails/rails/issues/32947
# Instead we need to fake some ENV Vars for the precompile ...
# Run precompile rake task in order to at least generate the manifest file
RUN SECRET_KEY_BASE=dummy bundle exec rake assets:precompile

# This font is used by imagemagick to add attribution to the images in the image library
# the DejaVu-Sans font is provided by the docker image this one is built on
ENV WATERMARK_FONT=DejaVu-Sans

# pass in a version while building with --build-arg CC_PORTAL_VERSION=x.y.z
ARG CC_PORTAL_VERSION
ENV CC_PORTAL_IMAGE_VERSION=$CC_PORTAL_VERSION

EXPOSE 3000

ENTRYPOINT [ "rails" ]
CMD [ "server" ]
#ENTRYPOINT [ "tail", "-f", "/dev/null" ]
