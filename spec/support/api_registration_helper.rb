shared_examples_for 'user registration' do
  let(:good_params) {
    { 
        first_name: "joe",
        last_name: "doe",
        login: "jdoe",
        password: "testingxxy",
        email: "jdoe@gmail.com"
    }
  }
  test_class = self.send(:described_class)

  def make(let_expression); end # Syntax sugar for our lets

  describe "user registration" do
    describe "Validation" do

      describe "With valid user parameters" do
        subject { test_class.new(good_params) }
        it { should be_valid }
      end
      
      describe "Missing some required parameter" do
        let(:bad_params) { Hash[good_params.to_a.sample(4)]}
        it { should_not be_valid }
      end

    end
  end
end
