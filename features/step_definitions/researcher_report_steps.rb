def modified_report_for(investigation)
  report  = Reports::Detail.new({:verbose => false, :investigations => [investigation]})
  report.stub!(:learner_id).and_return('learner_id')
  report.stub!(:user_id).and_return('user_id')
  report
end

def offering_for(investigation_name, class_name)
  clazz = Portal::Clazz.find_by_name(class_name)
  investigation = Investigation.find_by_name(investigation_name)
  offering  = find_or_create_offering(investigation, clazz)
end

def learner_for(student_name,offering)
  student   = User.find_by_login(student_name).portal_student
  learner   = offering.find_or_create_learner(student)
end

def filename_for_recorded(thing,name)
  thing_name  = thing.class.name.underscore.gsub("::","__").gsub("/","__")
  thing_name << name.gsub(/\s+/,"_")
  thing_name << ".yml"
  return Rails.root.join('features','recorded_objects',thing_name)
end

def record_data_for(thing,name)
  filename = filename_for_recorded(thing,name)
  if File.exists?(filename)
    puts "Recording for #{ thing.class.name } : #{name} exists. delete #{filename} to force new recording"
  else
    File.open(filename, "w") do |out|
      YAML.dump(thing, out)
    end
  end
end

def recorded_data_for(thing,name)
  serialized = nil
  File.open(filename_for_recorded(thing,name)) {|f| serialized = f.read}
  serialized
end

Then /^"([^"]*)" should have (\d+) answers for "([^"]*)" in "([^"]*)"$/ do |student_name, num_answers, investigation_name, class_name|
  offering = offering_for(investigation_name,class_name)
  learner = learner_for(student_name,offering)
  report = Report::Util.new(offering)
  report.complete_number(learner).should == num_answers.to_i
end

Then /^"([^"]*)" should have answered (\d+)% of the questions for "([^"]*)" in "([^"]*)"$/ do |student_name, percent, investigation_name,class_name|
  offering = offering_for(investigation_name,class_name)
  learner = learner_for(student_name,offering)
  report = Report::Util.new(offering)
  report.complete_percent(learner).should be_close(Float(percent), 1.5)
end

Then /^"([^"]*)" should have (\d+)% of the qeustions correctly for "([^"]*)" in "([^"]*)"$/ do |student_name, percent, investigation_name,class_name|
  offering = offering_for(investigation_name,class_name)
  learner = learner_for(student_name,offering)
  report = Report::Util.new(offering)
  report.correct_percent(learner).should be_close(Float(percent), 1.5)
end

Given /^the following assignments exist:$/ do |assignments_table|
  assignments_table.hashes.each do |hash|
    investigation_name = hash['investigation']
    clazz_name = hash['class']
    clazz = Portal::Clazz.find_by_name(clazz_name)
    investigation = Investigation.find_by_name(investigation_name)
    find_or_create_offering(investigation,clazz)
  end  
end


#Table: | student | class | investigation | question_prompt | answer |
Given /^the following student answers:$/ do |answer_table|
  answer_table.hashes.each do |hash|
    student = User.find_by_login(hash['student']).portal_student
    clazz = Portal::Clazz.find_by_name(hash['class'])
    investigation = Investigation.find_by_name(hash['investigation'])
    question = Embeddable::MultipleChoice.find_by_prompt(hash['question_prompt'])
    answer = question.choices.detect{ |c| c.choice == hash['answer']}
    offering = find_or_create_offering(investigation, clazz)
    learner = offering.find_or_create_learner(student)
    new_answer = Saveable::MultipleChoice.create(
      :learner => learner,
      :offering => offering,
      :multiple_choice => question
    ) 
    saveable_answer = Saveable::MultipleChoiceAnswer.create (
      #:bundle_contents => learner.bundle_contents,
      #:bundle_logger   => learner.bundle_logger,
      :choice          => answer
    )
    new_answer.answers << saveable_answer
  end
end

Given /^a recording of a report for "([^"]*)"$/ do |name|
  investigation = Investigation.find_by_name(name)
  buffer = StringIO.new
  spreadsheet = Spreadsheet::Workbook.new
  modified_report_for(investigation).run_report(buffer,spreadsheet)
  record_data_for(spreadsheet,name)
end

Then /^the report [^"]* "([^"]*)" should match recorded data$/ do |investigation_name|
  investigation = Investigation.find_by_name(investigation_name)
  buffer = StringIO.new
  spreadsheet = Spreadsheet::Workbook.new
  modified_report_for(investigation).run_report(buffer,spreadsheet)
  recorded_data = recorded_data_for(spreadsheet,investigation_name)
  recorded_data.should == YAML::dump(spreadsheet)
end


