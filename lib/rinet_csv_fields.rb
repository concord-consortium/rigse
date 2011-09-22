# Latest data descriptions can be found here:
# RITES SIS Integration 2011 - Google Docs http://bit.ly/rfPdJ5
# TODO: Use yaml for defining a set of field definitions
# TODO: Use a namespace 
# TODO: convert to a class

module RinetCsvFields

  def csv_field_columns
    {
      :students          => students_columns,
      :staff             => staff_columns,
      :courses           => courses_columns,
      :enrollments       => enrollments_columns,
      :staff_assignments => staff_assignments_columns
    }
  end

  def students_columns
     @students ||= [
      :Lastname ,
      :Firstname,
      :EmailAddress,
      :Birthdate,
      :SASID,
      :SchoolNumber,
      :District,
      :ClassYear,
      :HomeroomNumber,
      :BeginEnrollDate,
      :EndEnrollDate,
      :LASID
    ]
  end

  def staff_columns
    @staff ||= [
      :Lastname,
      :Firstname,
      :EmailAddress,
      :Phone,
      :Extention,
      :District,
      :SchoolNumber,
      :Password,
      :TeacherCertNum,
      :StaffType,
      :LocalStaffID
    ]
  end

  def courses_columns
    @courses ||= [
      :CourseNumber,
      :CourseSection,
      :Term,
      :Title,
      :Description,
      :StartDate,
      :EndDate,
      :SchoolNumber,
      :District,
      :Status,
      :CourseAbbreviation,
      :Department
    ]
  end

  def enrollments_columns
    @ernollments ||= [
      :SASID,
      :CourseNumber,
      :CourseSection,
      :Term,
      :District,
      :StartDate,
      :SchoolNumber,
      :Status
    ]
  end

  def staff_assignments_columns
    @staff_assignments ||= [
      :TeacherCertNum,
      :CourseNumber,
      :CourseSection,
      :Term,
      :District,
      :StartDate,
      :SchoolNumber
    ]
  end
end
