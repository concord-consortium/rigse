# encoding: utf-8

require 'spec_helper'


describe StudentRosterRow do
  let(:clazz)              { mock_model Portal::Clazz, id:4077  }
  let(:incomplete_student) { mock_model Portal::Student,
    user: nil,
    learners: nil
  }
  let(:login_time)         { nil }
  let(:good_login_time)    { Time.now - 1.hour }
  let(:completed_student)  { mock_model Portal::Student,
    user: mock_model(User, {
      last_name: "Malfoy",
      first_name: "Draco",
      login: "dmalfoy",
      last_sign_in_at: login_time
    }),
    learners: learners
  }
  let(:student)           { incomplete_student         }
  let(:name)              { nil                        }
  let(:login)             { nil                        }
  let(:signin_at)         { nil                        }
  let(:learners)          { nil                        }
  let(:good_learner)      { mock_model Portal::Learner }
  let(:roster_item)       { StudentRosterRow.new(student,clazz) }

  before(:each) do
    clazz.stub_chain(:student_clazzes,:find_by_student_id).and_return(clazz)
  end

  describe "A student without a valid user" do
    it "should use default values" do
      roster_item.name.should eql "No Name"
      roster_item.login.should eql "No Username"
      roster_item.last_login.should eql "Unknown"
      roster_item.assignments_started.should eql "Unknown"
    end
  end

  describe "A valid student" do
    let(:student) { completed_student }
    let(:learners) { [] }

    it "should use user attributes for fields" do
      roster_item.name.should eql "Malfoy, Draco"
      roster_item.login.should eql "dmalfoy"
    end

    describe "When the student has not done any work" do
      it "should list 0 assingments started" do
        roster_item.assignments_started.should eql 0
          roster_item.last_login.should eql "Never"
      end
    end

    describe "When the students learners are messed up" do
      let(:learners)   { [Object.new]    }
      let(:login_time) { good_login_time }
      it "should list 0 assingments started" do
        roster_item.assignments_started.should eql "Unknown"
        roster_item.last_login.should eql "about 1 hour ago"
      end
    end
    describe "when the student has started 2 activities in this class, and 1 in another class" do
      let(:item1) { Object.new }
      let(:item2) { Object.new }
      let(:item3) { Object.new }
      let(:learners) { [item1, item2] }
      it "should list 2 assignments started" do
        item1.stub_chain(:offering, :clazz_id).and_return(clazz.id)
        item2.stub_chain(:offering, :clazz_id).and_return(clazz.id)
        item3.stub_chain(:offering, :clazz_id).and_return(404)
        roster_item.assignments_started.should eql 2
      end
    end
  end
end
