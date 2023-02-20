require File.expand_path('../../../spec_helper', __FILE__)

describe Saveable::ImageQuestion do
  let(:offering) {mock_model(Portal::Offering)}
  let(:student)  {mock_model(Portal::Student) }
  let(:learner)  {mock_model(Portal::Learner, :student => student, :offering => offering)}
  let(:image_q)  {mock_model(Embeddable::ImageQuestion)}
  subject {Saveable::ImageQuestion.create(:learner => learner, :image_question => image_q )}
  describe "valid instance as a basis for testing" do
    it "should be valid" do
      expect(subject).to be_valid
    end
  end

  # TODO: auto-generated
  describe '#embeddable' do
    it 'embeddable' do
      image_question = described_class.new
      result = image_question.embeddable

      expect(result).to be_nil
    end
  end
end
