# Portal
module Portal
  @@models = [
    Portal::Course,
#    Portal::Semester,
#    Portal::Clazz,
#    Portal::SchoolMembership,
#    Portal::TeacherGradeLevel,
#    Portal::Subject,
#    Portal::GradeLevel,
#    Portal::School,
#    Portal::TeacherClazz,
#    Portal::StudentClazz,
#    Portal::Member,
#    Portal::Offering,
#    Portal::Learner,
#    Portal::District,
#    Portal::GrantProject,
    ]
  def self.configure_connections(configuration)
    @@models.each do |m|
      m.establish_connection(configuration)
    end
  end
end