FAKE_BLOBS_URL = "http://nowhere.com/dataservice/blobs"
def modified_report_for(investigation)
  report  = Reports::Detail.new(
    :verbose        => false,
    :runnables      => [investigation],
    :blobs_url      => FAKE_BLOBS_URL,
    :url_helpers    => Reports::UrlHelpers.new(:protocol => 'https', :host_with_port => 'portal.concord.org')
  )
  allow(report).to receive(:learner_id).and_return('learner_id')
  allow(report).to receive(:user_id).and_return('user_id')
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
    :multiple_choice => new_answer
  )
  Saveable::MultipleChoiceRationaleChoice.create(
    :choice          => answer,
    :answer          => saveable_answer
  )
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
  regexp = /"@url": #{FAKE_BLOBS_URL}\/(\d+)\/[a-f0-9]+\.(blob|png)/
  lines = structure.lines.select{ |l| l =~ regexp}
  if num
    num = num.to_i
    expect(num).to eq(lines.size)
  else
    expect(lines.size).not_to eq(0)
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
  expect(report.complete_number(learner)).to eq(num_answers.to_i)
end

Then /^"([^"]*)" should have answered (\d+)% of the questions for "([^"]*)" in "([^"]*)"$/ do |student_name, percent, investigation_name,class_name|
  offering = offering_for(investigation_name,class_name)
  learner = learner_for(student_name,offering)
  report = Report::Util.new(offering)
  expect(report.complete_percent(learner)).to be_within(1.5).of(Float(percent))
end

Then /^"([^"]*)" should have (\d+)% of the questions correctly for "([^"]*)" in "([^"]*)"$/ do |student_name, percent, investigation_name,class_name|
  offering = offering_for(investigation_name,class_name)
  learner = learner_for(student_name,offering)
  report = Report::Util.new(offering)
  expect(report.correct_percent(learner)).to be_within(1.5).of(Float(percent))
end


#Table: | student | class | investigation | question_prompt | answer |
Given /^the following student answers:$/ do |answer_table|
  assignable_type = answer_table.column_names[2]
  assignable_class = assignable_type.gsub(/\s/, "_").classify.constantize
  first_date = DateTime.now - answer_table.hashes.length
  answer_table.hashes.each_with_index do |hash, index|
    student = User.find_by_login(hash['student']).portal_student
    clazz = Portal::Clazz.find_by_name(hash['class'])
    assignable = assignable_class.find_by_name(hash[assignable_type])
    offering = find_or_create_offering(assignable, clazz)
    learner = offering.find_or_create_learner(student)
    add_response(learner,hash['question_prompt'],hash['answer'])
    report_learner = learner.report_learner
    # need to make sure the last_run is sequencial inorder for some tests to work
    report_learner.last_run = first_date + index
    report_learner.update_fields
  end
end

Given /^the student "([^"]*)" has run the investigation "([^"]*)" in the class "([^"]*)"$/ do |student, investigation, clazz|
  student = User.find_by_login(student).portal_student
  clazz = Portal::Clazz.find_by_name(clazz)
  investigation = Investigation.find_by_name(investigation)
  offering = find_or_create_offering(investigation, clazz)
  learner = offering.find_or_create_learner(student)
end

Then /^"([^"]*)" should have completed \((\d+)\) assessments for Activity "([^"]*)" in "([^"]*)"$/ do |student_name, num_answers, activity_name, class_name|
  activity = Activity.find_by_name(activity_name)
  investigation = activity.investigation
  offering = offering_for(investigation.name,class_name)
  learner = learner_for(student_name,offering)
  report = Report::Util.new(offering)
  expect(report.complete_number(learner,activity)).to eq(num_answers.to_i)
end

Then /^I should receive an Excel spreadsheet$/ do
  headers = page.driver.response.headers
  expect(headers).to have_key 'Content-Type'
  expect(headers['Content-Type']).to match "application/vnd.ms.excel"
end

Given /^the following researchers exist:$/ do |users_table|
  users_table.hashes.each do |hash|
    begin
      user = FactoryBot.create(:user, hash)
      user.add_role("member")
      user.add_role("researcher")
      user.save!
      user.confirm!
    rescue ActiveRecord::RecordInvalid
      # assume this user is already created...
    end
  end
end

Given /^a mocked remote endpoint url$/ do
  allow_any_instance_of(Reports::UrlHelpers).to receive(:remote_endpoint_url).and_return('https://portal.concord.org/dataservice/external_activity_data/1')
end
