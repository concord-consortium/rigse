require File.expand_path('../../../spec_helper', __FILE__)

describe Report::LearnerController do

  def new_learner(learner_stubs)
    learner = Factory(:full_portal_learner)
    learner_stubs.keys.each do |key|
      allow(learner).to receive(key).and_return(learner_stubs[key])
    end
    learner
  end

  before(:each) do
    allow(Report::Learner).to receive(:find_by_user_id_and_offering_id).and_return(learner)
  end

  let(:learner_stubs)   { {}                }
  let(:learner)         { new_learner(learner_stubs) }
  describe "A working test setup" do
    it "The learner should exist" do
      expect(learner).not_to be_nil
    end
  end

  describe "GET updated_at" do
    describe "when the learner has a valid updated_at" do
      let(:learner_stubs) { { last_run: Date.parse("1970-12-23") } }
      describe 'json format' do
        it "should return a json hash containing update_at time" do
          get :updated_at, :format => :json, :id => learner.id
          expect(response.status).to eq 200
          json = JSON.parse(response.body)
          expect(json['modification_time']).to eq('30758400')
        end
      end
      describe 'html format' do
        it "should return a string containing formatted time" do
          get :updated_at, :format => :html, :id => learner.id
          expect(response.status).to eq 200
          expect(response.body).to match '30758400'
        end
      end
    end

    describe "when the learner hasn't run anything yet" do
      let(:learner_stubs) { { last_run: nil } }
      let(:not_run_text)  { I18n.t "StudentHasntRun"}
      describe 'json format' do
        # Not sure about this.  I don't know what calls this method.
        it "should return an empty string" do
          get :updated_at, :format => :json, :id => learner.id
          json = JSON.parse(response.body)
          expect(response.status).to eq 400
          expect(json['modification_time']).to be_nil
          expect(json['error_msg']).to match not_run_text
        end
      end
      describe 'html format' do
        it "should return a string containing formatted time" do
          get :updated_at, :format => :html, :id => learner.id
          expect(response.status).to eq 400
          expect(response.body).to match not_run_text
        end
      end
    end
  end


end
