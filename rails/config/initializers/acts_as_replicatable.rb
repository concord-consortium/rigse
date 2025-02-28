require Rails.root.join("lib/acts_as_replicatable").to_s

Rails.application.config.to_prepare do
  ApplicationRecord.send :include, ActsAsReplicatable
end
