# encoding: UTF-8

# Returns itterable StudentRosterRows
# (students_in_class(portal_clazz.students)) }
# - roster_row = StudentRosterRow.new portal_student, portal_clazz
class StudentRoster

  attr_accessor :clazz
  attr_accessor :rows

  def initialize(_clazz)
    self.clazz = _clazz
    self.rows = self.clazz.students
      .includes( [:user, :learners => [:offering]] )
      .sort    { |a,b| (a.user.last_name.casecmp(b.user.last_name)) }
      .map     { |s| StudentRosterRow.new(s, self.clazz)            }
  end

  def empty?
    self.rows.length < 1
  end

  def each
    if block_given?
      self.rows.each { |e| yield(e) }
    end
  end
end
