class Saveable::ExternalLinkUrl < ActiveRecord::Base
  self.table_name = "saveable_external_link_urls"

  belongs_to :external_link,  :class_name => 'Saveable::ExternalLink', :counter_cache => :response_count
  belongs_to :bundle_content, :class_name => 'Dataservice::BundleContent'

  acts_as_list :scope => :external_link_id

  def answer
    url
  end

  def answer=(ans)
    url = ans
  end
end
