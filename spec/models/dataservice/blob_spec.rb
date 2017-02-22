require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::Blob do
  let(:attributes)  { {} }
  subject           { Dataservice::Blob.create!(attributes) }

  describe "a bare instance" do
    %w|content mimetype file_extension checksum learner_id|.each do |attr|
      it "should have a #{attr} attribute" do
        expect(subject.attributes).to include attr
      end
    end
  end

  describe "mimetype" do
    describe "with a mimetype attrbiute value set" do
      let(:attributes)  { {'mimetype' => "application/json"} }

      describe '#mimetype' do
        subject { super().mimetype }
        it {      is_expected.to eq("application/json") }
      end
    end
    describe "backwards compatibility, guessing mimetype" do
      describe "matching png by content" do
        let(:attributes) { {'content' => ".PNG blah blah"} }

        describe '#mimetype' do
          subject { super().mimetype }
          it { is_expected.to eq("image/png") }
        end
      end
      describe "default guess should be application/octet-stream" do
        describe '#mimetype' do
          subject { super().mimetype }
          it { is_expected.to eq("application/octet-stream")}
        end
      end
    end
  end

  describe "file_extension" do
    describe "with a file_extension attrbiute value set" do
      let(:attributes)    { {'file_extension' => "gif"} }

      describe '#file_extension' do
        subject { super().file_extension }
        it {      is_expected.to eq("gif") }
      end
    end
    describe "backwards compatibility, guess file_extension" do
      describe "by using mimetype info" do
        describe "guessing file_extension for image/png" do
          let(:attributes)     { {'mimetype' => "image/png"} }

          describe '#file_extension' do
            subject { super().file_extension }
            it { is_expected.to eq("png") }
          end
        end
        describe "guessing file_extension for application/octet-stream" do
          let(:attributes)     { {'mimetype' => "application/octet-stream"} }

          describe '#file_extension' do
            subject { super().file_extension }
            it { is_expected.to eq("blob") }
          end
        end
      end
      describe "guessing file_extension blindly" do
        describe '#file_extension' do
          subject { super().file_extension }
          it { is_expected.to eq("blob")}
        end
      end
    end
  end

  describe "html_content" do
    describe "for image mimetypes" do

      it "should render an image tag for jpegs" do
        subject.mimetype = "image/jpg"
        expect(subject.html_content("path")).to match /<img src/
      end

      it "should render an image tag for gifs" do
        subject.mimetype = "image/gif"
        expect(subject.html_content("path")).to match /<img src/
      end

      it "should render a div tag for others" do
        subject.mimetype = "application/octet-stream"
        expect(subject.html_content("path")).to match /<div/
      end
    end
  end

  describe "compute_checksum" do
    let(:attriutes) do
      {
        :content    => "simple content value here",
        :learner_id => 4
      }
    end

    describe "without hashable attrbiutes" do
      let(:attributes){}

      describe '#checksum' do
        subject { super().checksum }
        it { is_expected.not_to be_nil }
      end
    end

    it "should change when content changes" do
      first_checksum  = subject.checksum
      subject.content  = "updated content value here"
      expect(subject.checksum).not_to eq(first_checksum)
    end
  end

  describe "load_content_from(url)" do
    let (:url)         {"www.example.com/srpr/logo4w.png" }
    let (:mimetype)    { 'image/png'}
    let (:url_content) { 'this is the url content'}
    let (:status)      { 200 }
    let (:learner)     { mock_model(Portal::Learner, :id => '234234') }
    let (:atributes)   { { :learner => learner }}


    describe "making web requests" do
      before(:each) do
        stub_request(:get, url).
        to_return(:body => url_content, :status => status, :headers => { 'Content-Type' => mimetype})
      end

      describe "when there is good content" do
        let(:status) { 200 }
        it "should update its content with the content" do
          expect(subject.content).to be_nil
          subject.load_content_from(url)
          expect(subject.content).to eq(url_content)
        end
      end

      describe "when there is an http error" do
        let(:status) { 500 }
        it "should leave the content unchanged" do
          subject.content = "booga booga"
          subject.load_content_from(url)
          expect(subject.content).not_to eq(url_content)
        end
      end
    end

    describe "when the url is blank" do
      let(:url) { "" }
      # No need to stub a request either, because none will be made
      it "should not change the content" do
        expect(subject.content).not_to eq(url_content)
      end
    end

  end

  describe "class methods" do
    subject { Dataservice::Blob }
    describe "for_learner_and_content" do
      let(:url)              {"www.example.com/srpr/logo4w.png" }
      let(:mimetype)         { 'image/png'}
      let(:url_content)      { 'this is the url content'}
      let(:status)           { 200 }
      let(:learner)          { mock_model(Portal::Learner, :id => '234234') }
      let(:existing_content) { "prexisting content"}
      subject { Dataservice::Blob.for_learner_and_url(learner,url) }

      before(:each) do
        stub_request(:get, url).
        to_return(:body => url_content, :status => status, :headers => { 'Content-Type' => mimetype})
        @existing = Dataservice::Blob.create(:learner_id => learner.id, :content => existing_content )
      end

      describe "with new content and new learner" do
        it "should have correct values from loading content" do
          expect(subject.mimetype).to eq(mimetype)
          expect(subject.file_extension).to eq("png")
          expect(subject.content).to eq(url_content)
          expect(subject.id).not_to be_nil
          expect(subject).to be_valid
        end

        it "should not use an existing instance" do
          expect(subject).not_to eq(@existing)
          expect(subject.id).not_to eq(@existing.id)
        end
      end

      describe "with existing content and learner" do
        let(:existing_content)    { url_content }
        it "should reuse the existing instance" do
          expect(subject).to eq(@existing)
          expect(subject.content).to eq(existing_content)
          expect(subject.id).to eq(@existing.id)
        end
      end

    end
  end
end
