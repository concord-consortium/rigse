class MockupDataLoader
  
  def initialize
    yaml_dir = File.join(File.dirname(__FILE__), '..', 'test', 'fixtures')
    @users_path = File.join(yaml_dir, 'users.yml')
    @grade_levels_path = File.join(yaml_dir, 'portal_grade_levels.yml')
    @students_path = File.join(yaml_dir, 'portal_students.yml')
    @teachers_path = File.join(yaml_dir, 'portal_teachers.yml')
    @districts_path = File.join(yaml_dir, 'portal_districts.yml')
    @schools_path = File.join(yaml_dir, 'portal_schools.yml')
    @semesters_path = File.join(yaml_dir, 'portal_semesters.yml')
    @courses_path = File.join(yaml_dir, 'portal_courses.yml')
    @classes_path = File.join(yaml_dir, 'portal_clazzes.yml')
    @offerings_path = File.join(yaml_dir, 'portal_offerings.yml')
    @learners_path = File.join(yaml_dir, 'portal_learners.yml')
  end
  
  def load
    users = load_from_yaml(@users_path, User)
    process_users(users)
    
    grade_levels = load_from_yaml(@grade_levels_path, Portal::GradeLevel)
    process_grade_levels(grade_levels)
    
    investigations = load_investigations
    process_investigations(investigations, users)

    students = load_from_yaml(@students_path, Portal::Student)    
    process_students(students, users, grade_levels)
    
    teachers = load_from_yaml(@teachers_path, Portal::Teacher)    
    process_teachers(teachers, users)
    
    districts = load_from_yaml(@districts_path, Portal::District)    
    process_districts(districts)
    
    schools = load_from_yaml(@schools_path, Portal::School)    
    process_schools(schools, districts)
    
    semesters = load_from_yaml(@semesters_path, Portal::Semester)
    process_semesters(semesters, schools)
        
    courses = load_from_yaml(@courses_path, Portal::Course)
    process_courses(courses, schools)
    
    classes = load_from_yaml(@classes_path, Portal::Clazz)
    process_classes(classes, courses, semesters, teachers, students)
    
    offerings = load_from_yaml(@offerings_path, Portal::Offering)
    process_offerings(offerings, classes, investigations)
    
    learners = load_from_yaml(@learners_path, Portal::Learner)
    process_learners(learners, students, offerings)
  end
  
private

  def load_from_yaml(yml_path, model)
    records = {}
    yaml = YAML.load_file(yml_path)
    yaml.each do |name, attributes|
      records[name] = model.new(attributes)
      if model == User
        ## FIXME: User.new(attributes) doesn't pick up uuid
        ## Don't know why. Setting it directly:
        records[name].uuid = attributes['uuid']
      end
    end
    records
  end
  
  def process_users(users)
    users.each do |key, user|
      rec = save_rec(user)
      rec.register! if rec.state == 'passive' 
      rec.activate! if rec.state == 'pending'
      rec.save!
      users[key] = rec
    end
  end
  
  def process_students(students, users, grade_levels)
    students.each do |key, student|
      student.user = users[key]
    end 
    students['marcus'].grade_level = grade_levels['g_8']
    students['paul'].grade_level = grade_levels['g_8']
    students['maria'].grade_level = grade_levels['g_2']
    students['thomas'].grade_level = grade_levels['g_2']
    students.each { |key, s| students[key] = save_rec(s) }
  end
  
  def process_teachers(teachers, users)
    teachers.each do |key, teacher|
      teacher.user = users[key]
      teachers[key] = save_rec(teacher)
    end 
  end    
  
  def process_districts(districts)
    districts.each { |key, d| districts[key] = save_rec(d) }
  end
  
  def process_schools(schools, districts)
    schools['hogwarts'].district = districts['tzone']
    schools.each { |key, school| schools[key] = save_rec(school) }
  end
  
  def process_semesters(semesters, schools)
    semesters['hogwarts_fall_2009'].school = schools['hogwarts']
    semesters.each { |key, sem| semesters[key] = save_rec(sem) }
  end
  
  def process_courses(courses, schools)
    courses['elem_elec'].school = schools['hogwarts']
    courses['evolution'].school = schools['hogwarts']
    courses.each { |key, course| courses[key] = save_rec(course) }
  end
  
  def process_classes(classes, courses, semesters, teachers, students)
    classes['elem_elec_1'].course = courses['elem_elec']
    classes['elem_elec_1'].teacher = teachers['grigory']
    classes['elem_elec_1'].semester = semesters['hogwarts_fall_2009']
    classes['elem_elec_1'].students << students['marcus']      
    classes['elem_elec_2'].course = courses['elem_elec']
    classes['elem_elec_2'].teacher = teachers['grigory']
    classes['elem_elec_2'].semester = semesters['hogwarts_fall_2009']
    classes['evolution_1'].course = courses['evolution']
    classes['evolution_1'].teacher = teachers['homer']
    classes['evolution_1'].semester = semesters['hogwarts_fall_2009']
    classes.each { |key, c| classes[key] = save_rec(c) }
  end
  
  def process_learners(learners, students, offerings)
    learners['marcus_circuit_1'].student = students['marcus']
    learners['marcus_circuit_1'].offering = offerings['circuit_1'] 
    learners['paul_circuit_1'].student = students['paul']
    learners['paul_circuit_1'].offering = offerings['circuit_1']
    learners.each { |key, learner| learners[key] = save_rec(learner) }
  end
  
  def process_offerings(offerings, classes, investigations)
    offerings['circuit_1'].runnable = investigations['plant_1']
    offerings['circuit_1'].clazz = classes['elem_elec_1']
    offerings['plant_1'].runnable = investigations['plant_1']
    offerings['plant_1'].clazz = classes['evolution_1']
    offerings.each { |key, offering| offerings[key] = save_rec(offering) }
  end    
  
  def process_grade_levels(grade_levels)
    grade_levels.each { |key, level| grade_levels[key] = save_rec(level) }
  end

  def load_investigations
    invs = {}
    invs['plant_1'] = Investigation.new(
      :uuid => '6600B1CF-7B6D-4A5B-9498-11BB63764768',
      :name => 'Das Investigation',
      :description => 'Case of Benjamin Button',
      #:grade_span_expectation_id => 1,
      :teacher_only => false)
    invs
  end
  
  def process_investigations(invs, users)
    invs['plant_1'].user = users['grigory']
    invs.each { |key, inv| invs[key] = save_rec(inv) }
  end
  
  def save_rec(rec)
    old_rec = rec.class.find_by_uuid(rec.uuid)
    if old_rec
      old_rec.update_attributes(rec.attributes)
      return old_rec
    else
      rec.save!
      return rec
    end
  end
  
end
