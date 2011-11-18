class Fixups

  def self.switch_driver(vendor_interface_name='vernier_goio', old_driver_name='JNI', new_driver_name='JNA')
    new = Probe::VendorInterface.find_by_short_name_and_driver_short_name(vendor_interface_name,new_driver_name)
    old = Probe::VendorInterface.find_by_short_name_and_driver_short_name(vendor_interface_name,old_driver_name)
    if (old and new)
      def_p = Admin::Project.default_project
      enabled_new = proj = def_p.enabled_vendor_interfaces.include?(new)
      enabled_old = proj = def_p.enabled_vendor_interfaces.include?(old)
      unless enabled_new
        puts "WARNING: Enable the #{vendor_interface_name} #{new_driver_name} driver in project settings?"
      end
      if enabled_old
        puts "WARNING: Disable the #{vendor_interface_name} #{old_driver_name} driver in project settings?"
      end
      old_probe_users = User.all.select { |u| u.vendor_interface_id == old.id }
      puts "updating #{old_probe_users.size} users to use #{new_driver_name} interface"
      old_probe_users.each { |u| u.update_attribute(:vendor_interface, new) }
    else
      puts "could not find one or more #{vendor_interface_name} drivers."
      puts "run rake db:backup:load_probe_configurations to load them from config/probe_configurations"
    end
  end

  def self.destroy_teacher(teacher)
    teacher.clazzes.each(&:destroy)
    teacher.clazzes=[]
    # destroy could damage learner data.
    teacher.delete
    teacher = nil
  end

  def self.destroy_student(student)
    student.user.security_questions.each(&:destroy)
    student.destroy
    student = nil
  end

  def self.remove_teachers_test_students
    teachers = Portal::Teacher.all
    teachers.each do |teacher|
      user = teacher.user
      if user
        if user.portal_student
          puts "removing one student (#{user.portal_student.id}) (#{user.name} | #{user.id}) (#{user.portal_student.created_at})"
          self.destroy_student(user.portal_student)
          user.portal_student = nil
        end
      else
        puts "removing one bad teacher (#{teacher.id}) (null user) (#{teacher.created_at})"
        self.destroy_teacher(teacher)
      end
    end
  end

end
