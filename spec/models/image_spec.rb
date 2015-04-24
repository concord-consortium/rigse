require File.expand_path('../../spec_helper', __FILE__)

describe Image do
  before(:each) do
    Paperclip::Geometry.stub!(:from_file).and_return(dimensions)
  end

  let(:dimensions)  { mock(:width  => 100, :height => 100)}
  let(:license)     { mock_model(CommonsLicense, :code => 'CC-BY') }
  let(:user)        { mock_model(User, :login=>"testuser")}
  let(:img_filename){ "testing_file_name"                 }
  let(:name)        { "testing"                           }

  let(:attributes) do
    {
      'license'    => license,
      'name'            => name,
      'user'            => user,
      'image_file_name' => img_filename
    }
  end
  subject { Image.create(attributes)}

  describe "create" do
    context "with valid params" do
      it "should create a new instance given valid attributes" do
        subject.should be_valid
      end
    end

    context "with missing name" do
      let(:attributes) do
        {
          'license'    => license,
          'user'            => user,
          'image_file_name' => img_filename
        }
      end
      it "should produce errors on the model" do
        subject.should_not be_valid
      end
    end

    context "with missing user" do
      let(:attributes) do
        {
          'license'    => license,
          'name'            => name,
          'image_file_name' => img_filename
        }
      end

      it "should produce errors on the model" do
        subject.should_not be_valid
      end
    end

  end

  describe "check_image_presence" do
    it "should return true if the image_file_name isn't blank" do
    end
    it "should return false if the image_file_name is blank" do
    end

  end
  describe "clean_image_filename" do
    let(:image_mock)    { mock              }
    let(:with_slashes)  { "dangerous/name"  }
    let(:with_colons)   { "dangerous:name"  }
    let(:with_backticks){ "dangerous`name"  }
    let(:with_escapes)  { %q!dangerous\name!}
    let(:with_space)    { "dangerous name"  }
    let(:with_quotes)   { %q!dangerous"name!}
    let(:expected)      { "dangerous-name"}
    before(:each) {
      subject.stub(:image => image_mock)
      image_mock.should_receive(:instance_write).with(:file_name, expected)
    }
    context "with dangerous names" do
      it "should replace slashes" do
        subject.image_file_name = with_slashes
        subject.clean_image_filename
      end
      it "should replace colons" do
        subject.image_file_name = with_colons
        subject.clean_image_filename
      end
      it "should replace backticks" do
        subject.image_file_name = with_backticks
        subject.clean_image_filename
      end
      it "should replace escapes" do
        subject.image_file_name = with_escapes
        subject.clean_image_filename
      end
      it "should replace spaces" do
        subject.image_file_name = with_space
        subject.clean_image_filename
      end
      it "should replace quotes" do
        subject.image_file_name = with_quotes
        subject.clean_image_filename
      end
    end

    context "with safe names" do
      let(:expected) { "super-safe"}         # no change
      it "shouldn't modify non-threatening names" do
        subject.image_file_name = "super-safe" # no change
        subject.clean_image_filename
      end
    end
  end

  describe "save_image_dimensions" do

  end

  describe "Class Methods" do
    subject { Image }
    describe "can_be_created_by" do
      before(:each) do
        Admin::Settings.stub_chain(:default_settings, :teachers_can_author?).and_return(true)
      end


      it "wont let unprivledged users create" do
        user.should_receive(:has_role?).and_return(false)
        user.should_receive(:portal_teacher).and_return(nil)
        subject.can_be_created_by?(user).should be_false
      end
      it "will let privleged users creat things" do
        user.should_receive(:has_role?).and_return(true)
        subject.can_be_created_by?(user).should be_true
      end
    end
  end

  describe "redo_watermark" do
    before(:each) do
      @mock_image = mock
      subject.stub(:image => @mock_image)
    end
    it "shouldn't reprocess if processing is in progress" do
      subject.should_receive(:is_reprocessing).and_return(true)
      @mock_image.should_not_receive(:reprocess!)
      subject.redo_watermark
    end
    it "should reprocess if there is no proecessing in progress" do
      subject.should_receive(:is_reprocessing).and_return(false)
      subject.should_receive(:attribution_changed?).and_return(true)
      @mock_image.should_receive(:reprocess!)
      subject.redo_watermark
    end
  end

  describe "image_size" do
    before(:each) do
      @mock_image = mock
      subject.stub(:image => @mock_image)
    end
    it "should return the images size" do
      @mock_image.should_receive(:size).and_return(100)
      subject.image_size.should == 100
    end
    it "should return 0 even if there is no image" do
      @mock_image = nil
      subject.image_size.should == 0
    end
  end

  describe "uploaded_by_attribution" do
    context "when UseUploadedByInAttribution is set to true" do
      before(:each) do
        Image::UseUploadedByInAttribution = true
      end
      it "should return the users login" do
        subject.uploaded_by_attribution.should == "Uploaded by: testuser"
      end
    end
    context "when UseUploadedByInAttribution is set to false" do
      before(:each) do
        Image::UseUploadedByInAttribution = false
      end
      it "should return an empty string" do
        subject.uploaded_by_attribution.should be_blank
      end
    end
  end
end


