class Admin::SiteNotice < ActiveRecord::Base
  has_many :site_notice_roles
  has_many :site_notice_users
  validates :notice_html, :created_by, :presence => true
  
  
  @@NOTICE_DISPLAY_TYPES = {
    :no_notice => 1,
    :new_notices => 2,
    :collapsed_notices => 3
  }
  
  def self.NOTICE_DISPLAY_TYPES
    return @@NOTICE_DISPLAY_TYPES
  end
  
  def self.get_notices_for_user(user)
    
    notices_hash = {
      :notices => [],
      :notice_display_type => self.NOTICE_DISPLAY_TYPES[:no_notice]
    }
    
    # Notices should not be displayed for students    
    if user.portal_student
      return notices_hash
    end
    
    all_notices_ids = Array.new
    all_role_ids_of_user = Array.new
    all_roles = Role.all
    all_roles.each do |role|
      if(user.has_role?(role.title))
        all_role_ids_of_user << role.id
      end
    end
    
    notice_user_display_status = Admin::NoticeUserDisplayStatus.find_by_user_id(user.id)
    
    last_collapsed_at_time = DateTime.new(1990,01,01);
    
    if notice_user_display_status
      if notice_user_display_status.collapsed_status
        last_collapsed_at_time = notice_user_display_status.last_collapsed_at_time
      end
    end
    
    site_notice_roles = Admin::SiteNoticeRole.where(:role_id => all_role_ids_of_user)
    all_notices = []
    all_notice_ids = []
    latest_notice_at_time = DateTime.new(1990,01,01);
    
    if site_notice_roles
      site_notice_roles.each do |site_notice_role|
        site_notice = Admin::SiteNotice.find(site_notice_role.notice_id)
        
        if all_notice_ids.include?(site_notice.id)
          next
        end
        
        if site_notice.updated_at > latest_notice_at_time
          latest_notice_at_time = site_notice.updated_at
        end
        
        all_notice_ids << site_notice.id
        all_notices << site_notice
      end
    end
    
    all_notices_to_render = Array.new
    
    notice_display_type = self.NOTICE_DISPLAY_TYPES[:no_notice]
  
    dismissed_notice_ids = Admin::SiteNoticeUser.find_all_by_user_id_and_notice_dismissed(user.id, 1).map {|dn| dn.notice_id}
    
    all_notices.each do |notice|
      
      if dismissed_notice_ids.include?(notice.id)
        next
      end
      
      all_notices_to_render << notice
      
    end
    
    if ( (notice_user_display_status.nil?) ? true : (last_collapsed_at_time < latest_notice_at_time) )
      notice_display_type = self.NOTICE_DISPLAY_TYPES[:new_notices]
    elsif(last_collapsed_at_time >= latest_notice_at_time)
      notice_display_type = self.NOTICE_DISPLAY_TYPES[:collapsed_notices]      
    end
    
    
    if all_notices_to_render.length == 0
      notice_display_type = self.NOTICE_DISPLAY_TYPES[:no_notice]
    end
    
    notices_hash[:notices] = all_notices_to_render
    notices_hash[:notice_display_type] = notice_display_type
    
    return notices_hash
  end
end
