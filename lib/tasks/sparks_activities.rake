namespace :rigse do
  namespace :import do
    
    require 'fileutils'

    def sparks_activities_dir
      @sparks_activities_dir || @sparks_activities_dir = File.join(RAILS_ROOT, 'public', 'sparks-activities')
    end
    
    def git_update_sparks_activities
      Dir.chdir(sparks_activities_dir) do
        puts "\nupdating local git repository of sparks-activities: #{sparks_activities_dir}"
        `git svn rebase`
      end
    end

    def git_svn_clone_sparks_activities
      Dir.chdir(File.dirname(sparks_activities_dir)) do
        puts "\ncreating local git repository of sparks-activities: #{sparks_activities_dir}"
        `git svn clone https://svn.concord.org/svn/projects/trunk/sparks/sparks-content`
      end      
    end

    desc "create or update a git svn clone of sparks-activities"
    task :create_or_update_sparks_activities => :environment do
      if File.exists? File.join(sparks_activities_dir, '.git')
        git_update_sparks_activities
      else
        git_svn_clone_sparks_activities
      end
    end
  end
end


