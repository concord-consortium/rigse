namespace :researcher_dashboard do
  # Mints a runner token for manual testing against a deployed VM. These tokens are never
  # issued to a browser, so this task and the service-authenticated endpoint are the only
  # ways to obtain one.
  #
  # Usage: rake researcher_dashboard:runner_token SHAPE=session|class USER_ID=<user id> \
  #          CLASS_HASH=<class hash> FIREBASE_APP=<FirebaseApp name>
  #
  # USER_ID rather than USER, which every shell already sets to the unix account name.
  task runner_token: :environment do
    shape = ENV.fetch('SHAPE', 'session')
    unless %w[session class].include?(shape)
      abort "SHAPE must be 'session' or 'class', got #{shape.inspect}"
    end

    user = User.find(ENV.fetch('USER_ID'))
    class_hash = ENV.fetch('CLASS_HASH')
    firebase_app = ENV.fetch('FIREBASE_APP')

    token =
      if shape == 'session'
        ResearcherDashboard::RunnerToken.session_token(
          user: user, class_hash: class_hash, firebase_app: firebase_app
        )
      else
        ResearcherDashboard::RunnerToken.class_token(
          user: user, class_hash: class_hash, firebase_app: firebase_app
        )
      end

    warn "#{shape} runner token for user #{user.id} (#{user.login}), class_hash #{class_hash}, " \
         "firebase app #{firebase_app}, valid for #{ResearcherDashboard::RunnerToken::TTL} seconds:"
    puts token
  end
end
