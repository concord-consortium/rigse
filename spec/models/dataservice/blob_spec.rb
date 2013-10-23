require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::Blob do
  let(:attributes)  { {} }
  subject           { Dataservice::Blob.create!(attributes) }

  describe "a bare instance" do
    %w|content mimetype file_extension checksum learner_id|.each do |attr|
      it "should have a #{attr} attribute" do
        subject.attributes.should include attr
      end
    end
  end

  describe "mimetype" do
    describe "with a mimetype attrbiute value set" do
      let(:attributes)  { {'mimetype' => "application/json"} }
      its(:mimetype)    {      should == "application/json" }
    end
    describe "backwards compatibility, guessing mimetype" do
      describe "matching png by content" do
        let(:attributes) { {'content' => ".PNG blah blah"} }
        its(:mimetype)   { should == "image/png" }
      end
      describe "default guess should be application/octet-stream" do
        its(:mimetype)   { should == "application/octet-stream"}
      end
    end
  end

  describe "file_extension" do
    describe "with a file_extension attrbiute value set" do
      let(:attributes)    { {'file_extension' => "gif"} }
      its(:file_extension)      {      should == "gif" }
    end
    describe "backwards compatibility, guess file_extension" do
      describe "by using mimetype info" do
        describe "guessing file_extension for image/png" do
          let(:attributes)     { {'mimetype' => "image/png"} }
          its(:file_extension) { should == "png" }
        end
        describe "guessing file_extension for application/octet-stream" do
          let(:attributes)     { {'mimetype' => "application/octet-stream"} }
          its(:file_extension) { should == "blob" }
        end
      end
      describe "guessing file_extension blindly" do
        its(:file_extension)  { should == "blob"}
      end
    end
  end

  describe "html_content" do
    describe "for image mimetypes" do

      it "should render an image tag for jpegs" do
        subject.mimetype = "image/jpg"
        subject.html_content("path").should match /<img src/
      end

      it "should render an image tag for gifs" do
        subject.mimetype = "image/gif"
        subject.html_content("path").should match /<img src/
      end

      it "should render a div tag for others" do
        subject.mimetype = "application/octet-stream"
        subject.html_content("path").should match /<div/
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
      its(:checksum) { should_not be_nil }
    end

    it "should change when content changes" do
      first_checksum  = subject.checksum
      subject.content  = "updated content value here"
      subject.checksum.should_not == first_checksum
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
          subject.content.should be_nil
          subject.load_content_from(url)
          subject.content.should == url_content
        end
      end

      describe "when there is an http error" do
        let(:status) { 500 }
        it "should leave the content unchanged" do
          subject.content = "booga booga"
          subject.load_content_from(url)
          subject.content.should_not == url_content
        end
      end
    end

    describe "when the url is blank" do
      let(:url) { "" }
      # No need to stub a request either, because none will be made
      it "should not change the content" do
        subject.content.should_not == url_content
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
          subject.mimetype.should == mimetype
          subject.file_extension.should == "png"
          subject.content.should == url_content
          subject.id.should_not be_nil
          subject.should be_valid
        end

        it "should not use an existing instance" do
          subject.should_not == @existing
          subject.id.should_not == @existing.id
        end
      end

      describe "with existing content and learner" do
        let(:existing_content)    { url_content }
        it "should reuse the existing instance" do
          subject.should == @existing
          subject.content.should == existing_content
          subject.id.should == @existing.id
        end
      end

    end
  end
end
