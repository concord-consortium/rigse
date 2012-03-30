class Ccportal::ClassActivity < Ccportal::Ccportal
  self.table_name = :portal_class_activities
  self.primary_key = :class_activity_id

  belongs_to :course, :foreign_key => :class_id, :class_name => 'Ccportal::Course'
  belongs_to :activity, :foreign_key => :activity_id, :class_name => 'Ccportal::Activity'

  def self.findActivities(classId)
    activities = []
    cas = self.all.select { |ca| ca.class_id == classId }
    cas.each do |ca|
      begin 
        activity = Ccportal::Activity.find(ca.activity_id)
        activities << activity
      rescue ActiveRecord::RecordNotFound => e
        self.altLogger.error("ClassActivity.findActivities: #{e.class} #{e.to_s}")
      end 
    end
    activities
  end

  def self.altLogger
    AltLogger.getLogger
  end
  
end
