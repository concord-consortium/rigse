if File.exists?("#{RAILS_ROOT}/config/mailer.yml")
  require "action_mailer"
  c = YAML::load(File.open("#{RAILS_ROOT}/config/mailer.yml"))
  ActionMailer::Base.delivery_method = c[:delivery_method]
  ActionMailer::Base.smtp_settings = c[:smtp]
end