# some common tasks, hooks and definitions for sparks deploys

after 'deploy:make_directory_structure', 'deploy:make_sparks_directory_structure'
before 'deploy:create_symlink', 'import:create_or_update_sparks_content'
before 'import:create_or_update_sparks_content', 'deploy:sparks_shared_symlink'
after 'import:create_or_update_sparks_content', 'deploy:sparks_qucs_symlink'

namespace :import do
  # 01/27/2010
  desc "create or update a git svn clone of sparks-content"
  task :create_or_update_sparks_content, :roles => :app do
    run "cd #{release_path} && " +
    "bundle exec rake RAILS_ENV=#{rails_env} app:import:create_or_update_sparks_content --trace"
  end
end

namespace :deploy do
  task :make_sparks_directory_structure do
    run "mkdir -p #{shared_path}/public/sparks-content"
  end

  task :sparks_shared_symlink do
    run "ln -nfs #{shared_path}/public/sparks-content #{release_path}/public/sparks-content"
  end

  task :sparks_qucs_symlink do
    run "mkdir -p #{release_path}/public/sparks/qucsator"
    run "ln -nfs #{shared_path}/public/sparks-content/lib/qucsator/solve #{release_path}/public/sparks/qucsator/solve"
  end
end
