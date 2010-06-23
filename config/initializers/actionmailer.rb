if File.exists?("#{RAILS_ROOT}/config/mailer.yml")
  require "action_mailer"
  c = YAML::load(File.open("#{RAILS_ROOT}/config/mailer.yml"))
  c.each do |key,val|
    if key == :smtp || key == 'smtp'
      key = :smtp_settings
    end
    begin
      ActionMailer::Base.send("#{key}=".to_sym, val)
    rescue Exception => e
      $stderr.puts "Problem processing key '#{key}' in config/mailer.yml"
      $stderr.puts "#{e}"
    end
  end
end