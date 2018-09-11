
namespace :ci do

  if defined? Cucumber
    require 'cucumber/rake/task'

    # previously this also used `--tags ~@dialog ` to skip the dialog tests
    opts = %{--profile default --tags 'not @pending' --format progress}
    Cucumber::Rake::Task.new(:cucumber) do |t|
      t.cucumber_opts = opts
    end
    Cucumber::Rake::Task.new(:cucumber_without_javascript) do |t|
         t.cucumber_opts = opts + " --tags 'not @javascript'"
    end
    Cucumber::Rake::Task.new(:cucumber_javascript) do |t|
         t.cucumber_opts = opts + " --tags @javascript --tags 'not @search'"
    end
    Cucumber::Rake::Task.new(:cucumber_search) do |t|
         t.cucumber_opts = opts + " --tags @javascript --tags @search"
    end
  end

end
