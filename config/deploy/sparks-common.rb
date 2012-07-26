# some common tasks, hooks and definitions for sparks deploys

after 'deploy:symlink', 'import:create_or_update_sparks_content'
after 'deploy:make_directory_structure', 'deploy:make_sparks_directory_structure'
after 'deploy:shared_symlinks', 'deploy:sparks_shared_symlink'

namespace :import do
  # 01/27/2010
  desc "create or update a git svn clone of sparks-content"
  task :create_or_update_sparks_content, :roles => :app do
    run "cd #{deploy_to}/#{current_dir} && " +
    "bundle exec rake RAILS_ENV=#{rails_env} app:import:create_or_update_sparks_content --trace"
  end
end

namespace :deploy do
  task :make_sparks_directory_structure do
    run "mkdir -p #{shared_path}/public/sparks-content"
    run "mkdir -p #{shared_path}/public/sparks/qucsator"
  end

  task :sparks_shared_symlink do
    run "ln -nfs #{shared_path}/public/sparks-content #{release_path}/public/sparks-content"
    run "ln -nfs #{shared_path}/public/sparks-content/qucs #{release_path}/public/sparks/qucsator/solve"
  end
end
