require File.expand_path('../../../spec_helper', __FILE__)

describe Saveable::ImageQuestion do

  it_should_behave_like 'a saveable'

  # def add_external_answer(note,url)
  #   blob = Dataservice::Blob.for_learner_and_url(self.learner, url)
  #   self.answers.create(:blob_id => blob.id, :note => note)
  # end
  let(:offering) {mock_model(Portal::Offering)}
  let(:student)  {mock_model(Portal::Student) }
  let(:learner)  {mock_model(Portal::Learner, :student => student, :offering => offering)}
  let(:image_q)  {mock_model(Embeddable::ImageQuestion)}
  subject {Saveable::ImageQuestion.create(:learner => learner, :image_question => image_q )}
  describe "valid instance as a basis for testing" do
    it "should be valid" do
      subject.should be_valid
    end
  end

  describe "add_external_answer" do
    it "should create new answer with a blob" do
      blob = Dataservice::Blob.create()
      Dataservice::Blob.should_receive(:for_learner_and_url).and_return(blob)
      note = "this is the note"
      url  = "http://somelace.com/example.jgp"
      subject.add_external_answer(note, url)
      subject.answers.size.should == 1
      subject.answers.first.blob.should == blob
    end
  end

end
