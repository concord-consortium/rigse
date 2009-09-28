# Don't startup observers if we are running db:migrate -- they'll throw 
# an error accessing the models when running db:migrate from scratch
unless ( File.basename($0) == "rake" && ARGV.include?("db:migrate") ) 
  ActiveRecord::Base.observers = :user_observer, :investigation_observer
  ActiveRecord::Base.instantiate_observers
end