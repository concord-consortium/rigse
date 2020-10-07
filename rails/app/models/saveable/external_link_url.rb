class Saveable::ExternalLinkUrl < ActiveRecord::Base
  self.table_name = "saveable_external_link_urls"

  attr_accessible :external_link_id, :bundle_content_id, :position, :url, :is_final, :feedback, :has_been_reviewed, :score

  belongs_to :external_link,  :class_name => 'Saveable::ExternalLink', :counter_cache => :response_count
  belongs_to :bundle_content, :class_name => 'Dataservice::BundleContent'

  acts_as_list :scope => :external_link_id

  delegate :learner, to: :external_link, allow_nil: :true

  def answer
    url
  end

  def answer=(ans)
    url = ans
  end
end
