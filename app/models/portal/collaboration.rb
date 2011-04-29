class Portal::Collaboration < ActiveRecord::Base
  belongs_to :student, :class_name => "Portal::Student", :foreign_key => "student_id"
  belongs_to :bundle_content, :class_name => "Dataservice::BundleContent", :foreign_key => "bundle_content_id"
end

