FactoryBot.define do
  factory :site_notice, class: Admin::SiteNotice do |f|
    f.notice_html 'non white space characters'
    f.creator {FactoryBot.generate(:admin_user)}
  end
end

FactoryBot.define do
  factory :site_notice_role, class: Admin::SiteNoticeRole do |f|
  end
end

FactoryBot.define do
  factory :site_notice_user, class: Admin::SiteNoticeUser do |f|
  end
end

FactoryBot.define do
  factory :notice_user_display_status, class: Admin::NoticeUserDisplayStatus do |f|
  end
end
