module RinetCsvFields
  FIELD_DEFINITIONS = {
    # Birthdate         student’s birth date (yyyy-mm-dd)   Y
    # AdvisorID         advisor’s certification number   
    # SASID             state assigned student ID   Y
    # SchoolNumber      5 digit school ID assigned by state   Y
    # District          2 digit district ID assigned by state   Y
    # ClassYear         year student will graduate (YYYY)    
    # HomeroomNumber    student’s HR   
    # BeginEnrollDate   enrollment date (yyyy-mm-dd)   
    # EndEnrollDate     withdrawal date (yyyy-mm-dd)   
    # LASID             local student ID   
    # IEP               does student have an IEP (Y/N)   
    # LEP               special ed student? (Y/N)    
    # CounselorID       counselors’ certificate number   
    # HomeroomTeacher   HR teacher’s certificate number
    :students_fields => [
      :Lastname ,
      :Firstname,
      :EmailAddress,
      :Birthdate,
      :AdvisorID,
      :SASID,
      :SchoolNumber,
      :District,
      :ClassYear,
      :HomeroomNumber,
      :BeginEnrollDate,
      :EndEnrollDate,
      :LASID,
      :IEP,
      :LEP,
      :CounselorID,
      :HomeroomTeacher,
    ],

    # District            2 digit district ID assigned by state   Y
    # SchoolNumber        5 digit school ID assigned by state   Y
    # Password            Initial password for teacher  Y
    # TeacherCertNum      cert number assigned by RIDE  Y
    # StaffType           type of staff, usually Teacher   
    # LocalStaffID        local staff/faculty ID
    :staff_fields => [
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
        :LocalStaffID,
    ],

    # CourseNumber        course identifier   Y
    # CourseSection       section identifier  Y
    # Term                term the course takes place in  Y
    # Title               course title  Y
    # Description         brief course description   
    # StartDate           Date course starts (yyyy-mm-dd)   Y
    # EndDate             Date course ends (yyyy-mm-dd)   Y
    # SchoolNumber        5 digit school ID assigned by state   Y
    # District            2 digit district ID assigned by state   Y
    # Status              0=active course, 1=not active    
    # CourseAbbreviation  Title to use in the user interface  Y
    # Department          DepartmentID
    :courses_fields => [
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
      :Department,
    ],

    # SASID               state assigned student ID   Y
    # CourseNumber        course identifier   Y
    # CourseSection       section identifier  Y
    # Term                term the course takes place in  Y
    # District            2 digit district ID assigned by state   Y
    # StartDate           Date course starts (yyyy-mm-dd)   Y
    # SchoolNumber        5 digit school ID assigned by state   Y
    # Status              0=active course, 1=not active
    :enrollments_fields => [
      :SASID,
      :CourseNumber,
      :CourseSection,
      :Term,
      :District,
      :StartDate,
      :SchoolNumber,
      :Status,
    ],

    # TeacherCertNum      cert number assigned by RIDE    Y
    # CourseNumber        course identifier   Y
    # CourseSection       section identifier  Y
    # Term                term the course takes place in  Y
    # District            2 digit district ID assigned by state   Y
    # StartDate           Date course starts (yyyy-mm-dd)   Y
    # SchoolNumber        5 digit school ID assigned by state   Y
    :staff_assignments_fields => [
      :TeacherCertNum,
      :CourseNumber,
      :CourseSection,
      :Term,
      :District,
      :StartDate,
      :SchoolNumber,
    ],

    # TeacherCertNum      cert number assigned by RIDE    Y
    # SakaiLogin          Sakai Login generated by RINET
    :staff_sakai_fields => [
      :TeacherCertNum,
      :SakaiLogin
    ],

    # SASID               state assigned student ID   Y
    # SakaiLogin          Sakai Login generated by RINET
    :student_sakai_fields => [
      :SASID,
      :SakaiLogin
    ]
  }
end



