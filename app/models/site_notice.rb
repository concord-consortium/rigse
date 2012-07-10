class SiteNotice < ActiveRecord::Base
  validates :notice_html, :creator_id, :presence => true
end
