require 'spec_helper'


describe API::V1::OfferingsController do

  let(:runnable)          { Factory.create(:activity, runnable_opts)    }
  let(:offering)          { Factory(:portal_offering, offering_opts)    }
  let(:clazz)             { Factory(:portal_clazz, teachers: [class_teacher], students:[student_a,student_b]) }
  let(:offering_opts)     { {clazz: clazz, runnable: runnable}   }
  let(:runnable_opts)     { {name: 'the activity'}              }
  let(:admin_user)        { Factory.next(:admin_user)           }
  let(:class_teacher)     { Factory.create(:portal_teacher)     }
  let(:student_a)         { Factory.create(:full_portal_student)}
  let(:student_b)         { Factory.create(:full_portal_student)}
  let(:user)              { class_teacher.user                  }

  before(:each) do
    Portal::Offering.stub!(:find).and_return(offering)
    sign_in user
  end

  # TODO:  Add answers &etc to make this test more meaningful
  describe "GET show" do
    describe "For the offering's teacher" do
      it 'it should render the report json' do
        get :show, :id => offering.id
        response.status.should eql(200)
        report = JSON.parse(response.body)
        report["activity"].should eql "the activity"
        report["students"][0].should include("started_activity"=>false)
        report["students"][0].should include("name"=>"joe user")
      end
    end
  end
end