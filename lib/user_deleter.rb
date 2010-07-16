#class ActiveRecord::Base
#  # stub out the destroy method
#  def destroy
#    puts "Psych! not going to destroy: #{self.class} #{self.id} #{self}"
#  end
#end
#
#class Investigation
#  def deep_set_user(user)
#    puts "Psych! Not going to reown this investigation: #{self.id} : #{self.name}"
#  end
#end

class UserDeleter 
  DEFAULT_OWNER_LOGIN = "knowuh"
  attr_accessor :keep_list
  attr_accessor :default_owner

  def initialize(options = {})
    new_date = 4.months.ago
    exception_list = %q[ knowuh ed ehazzard freichsman manager teacher student anonymous guest manager admin].split
    self.keep_list = User.find(:all, :conditions => ["login in (?)", exception_list]);
    
    new_users = User.find(:all, :conditions => "created_at > '#{new_date}'")
    admin_users =  User.with_role('admin')
    manager_users = User.with_role('manager')
    report_users = User.find(:all, :conditions => "login like 'report%'")
    sakai_users =  User.find(:all, :conditions => "login like '%_rinet_sakai'")
    team_users = User.find(:all, :conditions => "last_name like '%team%'")

    self.keep_list = self.keep_list + new_users
    self.keep_list = self.keep_list + manager_users
    self.keep_list = self.keep_list + admin_users
    self.keep_list = self.keep_list + team_users
    self.keep_list = self.keep_list - report_users
    self.keep_list = self.keep_list - sakai_users

    self.keep_list.uniq!

    self.default_owner = User.find_by_login(DEFAULT_OWNER_LOGIN)
  end
  


  def nuclear
    delete_old_investigations
    delete_all(User.find(:all))
  end

  def delete_old_investigations(from="2010")
    to_delete = Investigation.find(:all, :conditions => "created_at < '#{from}'")
    to_delete = to_delete - Investigation.published
    to_delete.each do |investigation|
      investigation.destroy
    end
  end
  
  def delete_all(user_list=User.find(:all, :conditions => "login like '%rinet_sakai%'"))
    user_list = user_list - self.keep_list
    user_list.each do |user|
      print "Removing user: #{user.login} #{user.email}::::"
      delete_user(user)
      puts "\n"
    end
  end

  def reown_investigations(user)
    user.investigations.each { |i|
      i.deep_set_user(self.default_owner)
      print "I"
    }
  end
  
  def delete_user(user)
    reown_investigations(user)
    delete_clazzes(user)
    delete_student(user)
    user.destroy
  end


  def delete_student(user)
    if user.portal_student
      user.portal_student.destroy
      print "S"
    end
  end
  
  def delete_clazzes(user)
    if user.portal_teacher
      if user.portal_teacher.clazzes
        user.portal_teacher.clazzes.each do |clazz|
          clazz.destroy
          print "C"
        end
      end
      user.portal_teacher.destroy
      print "T"
    end
  end

end
