def update_logging(status,classids)
  if classids == "all"
    Portal::Clazz.all.each do |clazz|
      clazz.logging = status
      if clazz.save(:validation => false)
        puts "class id #{clazz.id} : Success"        
      end
    end
  else
    class_ids = classids.split(",")
    class_ids = class_ids.uniq
    class_ids.each do |class_id|
      if(Portal::Clazz.exists?(class_id))
        clazz = Portal::Clazz.find(class_id)
        clazz.logging = status
        if clazz.save(:validation => false)
          puts "class id #{class_id} : Success"          
        end
      else
        puts "class id #{class_id} : Invalid"       
      end
    end  
  end
end

namespace :portal_class_logging do
  require 'highline/import'

  desc "enable logging for classes"
  task :enable_logging => :environment  do |t,args|
    classids = ask("Enter ActivieRecord ids of classes: ") { |s| s.default = "all" }
    update_logging(true,classids)
  end
  
  desc "disable logging for classes"
  task :disable_logging => :environment  do |t,args|
    classids = ask("Enter ActivieRecord ids of classes: ") { |s| s.default = "all" }
    update_logging(false,classids)
  end
end
