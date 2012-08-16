Factory.define :site_notice, class: Admin::SiteNotice  do |f|
  f.notice_html 'non white space characters'
end

Factory.define :site_notice_role, class: Admin::SiteNoticeRole do |f|
end

Factory.define :site_notice_user, class: Admin::SiteNoticeUser do |f|
end

Factory.define :notice_user_display_status,class: Admin::NoticeUserDisplayStatus do |f|
end
