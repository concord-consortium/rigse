shared_examples_for 'a saveable' do

  let(:model_name) { described_class.name.underscore_module }
  let(:saveable)   { Factory.create model_name }

  
  describe "belong to an embeddable and" do
    it "respond to embeddable?" do
      expect(saveable).to respond_to :embeddable
    end
    it "return an embeddable instance" do
      expect(saveable.embeddable).to_not be_nil
    end
  end

  describe "score and feedback for answers" do
    def add_answer
      saveable.answers.create

      if described_class == Saveable::MultipleChoice
        saveable.answers.last.rationale_choices.create

        #
        # Stubbing the #answer method since its return is derived from some
        # complex relationships
        #
        Saveable::MultipleChoiceAnswer.any_instance.stub(
            :answer =>
                [ { :choice_id => 1, :answer => "non-default answer" } ] )
      end

      if described_class == Saveable::OpenResponse
        #
        # For open response, set the :answer attribute to some non-empty value
        #
        saveable.answers.last.update_attribute(:answer, "non-empty answer")
      end

    end

    def add_score(score)
      saveable.answers.last.update_attribute(:score, score)
    end

    def add_feedback(feedback)
      saveable.answers.last.update_attribute(:feedback, feedback)
    end

    def review_answer
      saveable.answers.last.update_attribute(:has_been_reviewed, true)
    end

    describe "#needs_review?" do
      subject { saveable.needs_review? }
      describe "with no answers" do
        it { should be_false }
      end
      describe "with an answer" do
        before(:each) do
          add_answer
        end

        describe "when no feedback has been given" do
          it { should  be_true }
        end

        describe "when the answer has been reviewed" do
          before(:each) do
            review_answer
          end
          it { should be_false }
        end

      end
    end

    describe "#current_feedback" do
      subject { saveable.current_feedback }
      describe "with no answers" do
        it { should be_nil }
      end
      describe "with an answer" do
        before(:each) do
          add_answer
        end

        describe "when no feedback has been given" do
          it { should  be_nil }
        end

        describe "when we give feeback" do
          let(:feedback) { "great_job" }
          before(:each) do
            add_feedback(feedback)
          end
          it { should eq feedback }
        end

      end
    end

    describe "#current_score" do
      subject { saveable.current_score }
      describe "with no answers" do
        it { should be_nil }
      end
      describe "with an answer" do
        before(:each) do
          add_answer
        end

        describe "when no score has been given" do
          it { should  be_nil }
        end

        describe "when we score the work" do
          let(:score) { 5 }
          before(:each) do
            add_score(score)
          end
          it { should eq score }
        end

      end
    end

  end
end
