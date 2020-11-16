class Dataservice::BucketContent < ActiveRecord::Base
  belongs_to :bucket_logger, :class_name => "Dataservice::BucketLogger", :foreign_key => "bucket_logger_id"
end
