require 'rake'

namespace :app do
  namespace :make do
    #
    #
    #
    desc 'wrap orphaned activities in a parent investigation'
    task :investigations => :environment do
      puts "Creating parent investiations for activities without a parent."
      ParentInvestigation.parent_activities # see lib/parent_investigations.rb
    end
  end
end