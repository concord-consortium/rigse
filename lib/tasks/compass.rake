namespace :compass do
  desc "compile sass files. (manually before use on production -- good for assset packing"
  task :compile => :environment do
    # this is dumb, we should just use the Compass class itself, but I am lazy.
    %x{compass --sass-dir public/stylesheets/sass/ --css-dir public/stylesheets/ -s compressed}
  end
end