class Portal::StudentClazz < ApplicationRecord
  self.table_name = :portal_student_clazzes

  acts_as_replicatable

  belongs_to :clazz, :class_name => "Portal::Clazz", :foreign_key => "clazz_id"
  belongs_to :student, :class_name => "Portal::Student", :foreign_key => "student_id"

  [:name, :description].each { |m| delegate m, :to => :clazz }

  after_destroy :remove_user_offering_metadata

  private

  def remove_user_offering_metadata
    self.clazz.offerings.each do |offering|
      metadata = UserOfferingMetadata.find_by(user_id: self.student.user.id, offering_id: offering.id)
      metadata.destroy if metadata
    end
  end

end
