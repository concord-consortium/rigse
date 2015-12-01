class API::V1::DashboardReport
  include Virtus.model

  class DashStudent
    include Virtus.model
    attribute :student, String
    attribute :learner_id, Integer
    def initialize(student, offering)
      self.student = "#{student.user.name}"
      self.learner_id = offering.learners.where(student_id: student.id).pluck(:id).first
    end
  end

  attribute :teacher, Integer
  attribute :students, Array[DashStudent]
  attribute :clazz, String
  attribute :offering, String
  attribute :offering_url, String

  def initialize(offering)
    self.teacher = offering.clazz.teacher.name
    self.clazz = offering.clazz.name
    self.offering = offering.name
    self.offering_url = offering.runnable.url
    self.students = offering.clazz.students.map { |s| DashStudent.new(s,offering)}
  end

end
