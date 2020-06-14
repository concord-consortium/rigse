namespace :compass do
  desc "compile sass files. (manually before use on production -- good for assset packing"
  task :compile => :environment do
    # this is dumb, we should just use the Compass class itself, but I am lazy.
    %x{bundle exec compass compile --sass-dir public/stylesheets/scss/ --css-dir public/stylesheets/ -s compact --force}
  end
end