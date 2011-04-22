FAKE_BLOBS_URL = "http://nowhere.com/dataservice/blobs"
def modified_report_for(investigation)
  report  = Reports::Detail.new(
    :verbose        => false,
    :investigations => [investigation],
    :blobs_url      => FAKE_BLOBS_URL
  )
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

def add_response(learner,prompt_text,answer_text)
  prompts = {}
  Embeddable::MultipleChoice.all.each  { |q| prompts[q.prompt] = q}
  Embeddable::OpenResponse.all.each    { |q| prompts[q.prompt] = q}
  Embeddable::ImageQuestion.all.each   { |q| prompts[q.prompt] = q}
  Embeddable::MultipleChoice.all.each  { |q| prompts[q.prompt] = q}
  question = prompts[prompt_text]
  puts "No Question found for #{prompt_text}" if question.nil?
  return if question.nil?
  case question.class.name
  when "Embeddable::MultipleChoice" 
    return add_multichoice_answer(learner,question, answer_text)
  when "Embeddable::OpenResponse"
    return add_openresponse_answer(learner,question, answer_text)
  when "Embeddable::ImageQuestion"
    return add_image_question_answer(learner,question, answer_text)
  end
end

def add_multichoice_answer(learner,question,answer_text)
  answer = question.choices.detect{ |c| c.choice == answer_text}
  new_answer = Saveable::MultipleChoice.create(
    :learner => learner,
    :offering => learner.offering,
    :multiple_choice => question
  ) 
  saveable_answer = Saveable::MultipleChoiceAnswer.create(
    #:bundle_contents => learner.bundle_contents,
    #:bundle_logger   => learner.bundle_logger,
    :choice          => answer
  )
  new_answer.answers << saveable_answer
end

def add_openresponse_answer(learner,question,answer_text)
  new_answer = Saveable::OpenResponse.create(
    :learner => learner,
    :offering => learner.offering,
    :open_repsonse => question
  ) 
  saveable_answer = Saveable::OpenResponseAnswer.create(
    :answer          => answer_text
  )
  new_answer.answers << saveable_answer
end


def add_image_question_answer(learner,question,answer_text)
  return nil if (answer_text.nil? || answer_text.strip.empty?)
  new_answer = Saveable::ImageQuestion.create(
    :learner => learner,
    :offering => learner.offering,
    :image_question => question
  ) 
  # TODO: Maybe slurp in some image and encode it for the blob?
  saveable_answer = Saveable::ImageQuestionAnswer.create(
    :blob => Dataservice::Blob.create(
      :content => answer_text,
      :token => answer_text
    )
  )
  new_answer.answers << saveable_answer
end

def find_bloblinks_in_spreadheet(spreadsheet,num)
  structure = YAML::dump(spreadsheet)
  regexp = /"@url": #{FAKE_BLOBS_URL}\/(\d+)\.blob/
  lines = structure.lines.select{ |l| l =~ regexp}
  if num
    num = num.to_i
    num.should == lines.size
  else
    lines.size.should_not == 0
  end
end

def assessments_completed_for(spreadsheet,student,runnable=nil)
  sheet = spreadsheet.worksheets.first
  header = sheet.rows[0]
  student_row_number = 4 # todo more dynamic way of finding user_id?
  #debugger
  student_row = sheet.rows.detect { |r| r[student_row_number].strip.downcase == student.strip.downcase }
  if offering
    runnable_column_number = header.index { |r| r.to_s =~ /.*#{runnable}.*assessments\s+completed/i }
  else
    runnable_column_number = header.index { |r| r.to_s =~ /.*#{runnable}.*assessments\s+completed/i }
  end
  student_row[runnable_column_number]
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

Then /^"([^"]*)" should have (\d+)% of the questions correctly for "([^"]*)" in "([^"]*)"$/ do |student_name, percent, investigation_name,class_name|
  offering = offering_for(investigation_name,class_name)
  learner = learner_for(student_name,offering)
  report = Report::Util.new(offering)
  report.correct_percent(learner).should be_close(Float(percent), 1.5)
end


#Table: | student | class | investigation | question_prompt | answer |
Given /^the following student answers:$/ do |answer_table|
  answer_table.hashes.each do |hash|
    student = User.find_by_login(hash['student']).portal_student
    clazz = Portal::Clazz.find_by_name(hash['class'])
    investigation = Investigation.find_by_name(hash['investigation'])
    offering = find_or_create_offering(investigation, clazz)
    learner = offering.find_or_create_learner(student)
    add_response(learner,hash['question_prompt'],hash['answer'])
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

Then /^the report generated for "([^"]*)" should have \((\d+)\) links to blobs$/ do |investigation_name, num_blobs|
  investigation = Investigation.find_by_name(investigation_name)
  buffer = StringIO.new
  spreadsheet = Spreadsheet::Workbook.new
  modified_report_for(investigation).run_report(buffer,spreadsheet)
  find_bloblinks_in_spreadheet(spreadsheet,num_blobs)
end

Then /^the usage report for "([^"]*)" should have \((\d+)\) answers for "([^"]*)"$/ do |investigation_name,value,student|
  pending
  # The reason this is pending is beause the assessments_completed_for method at the top of this file needs help.
  #
  #buffer = StringIO.new
  #spreadsheet = Spreadsheet::Workbook.new
  #investigation = Investigation.find_by_name(investigation_name)
  #report  = Reports::Usage.new(:investigations => Investigation.all)
  #report.run_report(buffer,spreadsheet)
  #assessments_completed_for(spreadsheet,student,investigation_name).strip.downcase.should == value.strip.downcase
end

Then /^"([^"]*)" should have completed \((\d+)\) assessments for Activity "([^"]*)" in "([^"]*)"$/ do |student_name, num_answers, activity_name, class_name|
  activity = Activity.find_by_name(activity_name)
  investigation = activity.investigation
  offering = offering_for(investigation.name,class_name)
  learner = learner_for(student_name,offering)
  report = Report::Util.new(offering)
  report.complete_number(learner,activity).should == num_answers.to_i
end

