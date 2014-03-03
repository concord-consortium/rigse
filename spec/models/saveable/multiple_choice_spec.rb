require File.expand_path('../../../spec_helper', __FILE__)

describe Saveable::MultipleChoice do

  it_should_behave_like 'a saveable'

  # Check that last_answer is updated whenever a new answer is added
  it "should update the last_answer" do
  	multiple_choice_saveable = Saveable::MultipleChoice.create()
  	$multiple_choice = multiple_choice_saveable
  	answer_one = multiple_choice_saveable.answers.create
  	answer_two = multiple_choice_saveable.answers.create
  	# this is necessary because inverse_of doesn't work on callbacks
  	# https://github.com/rails/rails/pull/12359
  	# if we go up to rails 3.2.17 this is fixed
  	multiple_choice_saveable.reload
  	multiple_choice_saveable.last_answer.should == answer_two
  end
end
