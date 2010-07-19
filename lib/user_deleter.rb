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
  DEFAULT_OWNER_LOGIN = "freichsman"
  attr_accessor :keep_list
  attr_accessor :default_owner

  def initialize(options = {})
    save_these_logins = %q[
      fogleman DAN gdeoliveira hdooley
      knowuh ehazzard freichsman stephen cstaudt nkimball abean
      manager teacher student anonymous guest admin].split


    self.keep_list = User.find(:all, :conditions => ["login in (?)", save_these_logins]);
    concord_users =  User.find(:all, :conditions => "email like '%concord.org'")
    no_email_users = User.find(:all, :conditions => "email like 'no-email%'")
    published_authors = Investigation.published.map { |i| i.user }

    # new_users = User.find(:all, :conditions => "created_at > '#{new_date}'")
    admin_users =  User.with_role('admin')
    manager_users = User.with_role('manager')
    report_users = User.find(:all, :conditions => "login like 'report%'")
    sakai_users =  User.find(:all, :conditions => "login like '%_rinet_sakai'")
    team_users = User.find(:all, :conditions => "last_name like '%team%'")

    # build a keep list:
    self.keep_list = self.keep_list + manager_users
    self.keep_list = self.keep_list + admin_users
    self.keep_list = self.keep_list + team_users
    self.keep_list = self.keep_list + concord_users
    self.keep_list = self.keep_list + published_authors

    # build a remove list:
    self.keep_list = self.keep_list - report_users
    self.keep_list = self.keep_list - sakai_users
    self.keep_list = self.keep_list - no_email_users
    self.keep_list.uniq!

    self.default_owner = User.find_by_login(DEFAULT_OWNER_LOGIN)
  end
  
  def delete_all
    delete_user_list(User.find(:all))
  end

  def delete_user_list(user_list=User.find(:all, :conditions => "login like '%rinet_sakai%'"))
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
