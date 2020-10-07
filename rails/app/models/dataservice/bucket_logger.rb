class Dataservice::BucketLogger < ActiveRecord::Base
  attr_accessible :learner, :learner_id, :name

  belongs_to :learner, :class_name => "Portal::Learner", :foreign_key => "learner_id"
  has_many :bucket_contents, -> { order :updated_at }, :dependent => :destroy ,:class_name => "Dataservice::BucketContent", :foreign_key => 'bucket_logger_id'

  has_many :bucket_log_items, -> { order :updated_at }, :dependent => :destroy, :class_name => "Dataservice::BucketLogItem", :foreign_key => 'bucket_logger_id'

  def most_recent_content
    # don't use .last because that has weird interactions with has_many
    most_recent = self.bucket_contents[-1]
    most_recent ? most_recent.body : ""
  end
end
