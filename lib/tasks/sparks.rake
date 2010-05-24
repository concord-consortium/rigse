require 'johnson'
require 'json/ext'

namespace :sparks do

  def create_student(user_attributes, grade_level, portal_clazz)
    user = User.new(user_attributes)
    user.skip_notifications = true
    user.register!
    user_created = user.save
    if user_created
      user.activate!
      student = Portal::Student.create(:user_id => user.id,
                                       :grade_level_id => grade_level.id)
      student.student_clazzes.create!(:clazz_id => portal_clazz.id,
                                      :student_id => student.id,
                                      :start_time => Time.now)
      puts "Created #{user.login}"
    else
      puts "Failed to create student #{user_attributes[:login]}"
    end
  end
  
  desc "Re-grade all saved Measuring Resistance instances"
  task :regrade_mr => :environment do
    report_js = "#{RAILS_ROOT}/public/sparks-content/server-mr-report.js"
    rt  = Johnson::Runtime.new
    rt.load(report_js)
    cnt=1

    script = <<HERE
try {
  grader = new sparks.activities.mr.Grader(logObj);
  feedback = grader.grade();
  result = JSON.stringify(feedback);
}
catch (e) {
  result = 'ERROR: ' + e;
}
result;
HERE

    Saveable::Sparks::MeasuringResistanceReport.all.each do |r|
      rt['logObj'] = JSON.parse(r.content)[0]
      result = rt.evaluate(script)
      if result =~ /^ERROR/
        puts "\nMeasuringResistanceReport id=#{r.id} #{result}"
      else
        r.graded_result = result
        r.save!
      end
      cnt += 1
      #puts("#{cnt} #{result[0,10]}")
      print '.' if cnt % 10 == 0
    end
    puts
  end
  
  desc "Create 100 students for TCC Engineering Day"
  task :create_100_students => :environment do
    portal_clazz = Portal::Clazz.find_by_class_word('highschool')
    grade_level = portal_clazz.teacher.grade_levels[0]
    1.upto(100) do |i|
      username = "student#{i}"
      password = "sparks#{i}"
      create_student({
                       :login => username,
                       :password => password,
                       :password_confirmation => password,
                       :first_name => 'Student',
                       :last_name =>  '%03d' % i,
                       :email => Portal::Student.generate_user_email
                     },
                     grade_level,
                     portal_clazz
                     )
    end
  end

end
