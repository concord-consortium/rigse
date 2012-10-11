class Dataservice::BucketLogItem < ActiveRecord::Base
  attr_accessible :content, :bucket_logger, :bucket_logger_id

  belongs_to :bucket_logger, :class_name => "Dataservice::BucketLogger", :foreign_key => "bucket_logger_id"
end
