class Dataservice::BucketContent < ApplicationRecord
  belongs_to :bucket_logger, :class_name => "Dataservice::BucketLogger", :foreign_key => "bucket_logger_id"
end
