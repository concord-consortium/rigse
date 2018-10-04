require File.expand_path('../../spec_helper', __FILE__)

describe Image do
  before(:each) do
    allow(Paperclip::Geometry).to receive(:from_file).and_return(dimensions)
  end

  let(:dimensions)  { double(:width  => 100, :height => 100)}
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
        expect(subject).to be_valid
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
        expect(subject).not_to be_valid
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
        expect(subject).not_to be_valid
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
    let(:image_mock)    { double              }
    let(:with_slashes)  { "dangerous/name"  }
    let(:with_colons)   { "dangerous:name"  }
    let(:with_backticks){ "dangerous`name"  }
    let(:with_escapes)  { %q!dangerous\name!}
    let(:with_space)    { "dangerous name"  }
    let(:with_quotes)   { %q!dangerous"name!}
    let(:expected)      { "dangerous-name"}
    before(:each) {
      allow(subject).to receive_messages(:image => image_mock)
      expect(image_mock).to receive(:instance_write).with(:file_name, expected)
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
        allow(Admin::Settings).to receive_message_chain(:default_settings, :teachers_can_author?).and_return(true)
      end


      it "wont let unprivledged users create" do
        expect(user).to receive(:has_role?).and_return(false)
        expect(user).to receive(:portal_teacher).and_return(nil)
        expect(subject.can_be_created_by?(user)).to be_falsey
      end
      it "will let privleged users creat things" do
        expect(user).to receive(:has_role?).and_return(true)
        expect(subject.can_be_created_by?(user)).to be_truthy
      end
    end
  end

  describe "redo_watermark" do
    before(:each) do
      @mock_image = double
      allow(subject).to receive_messages(:image => @mock_image)
    end
    it "shouldn't reprocess if processing is in progress" do
      expect(subject).to receive(:is_reprocessing).and_return(true)
      expect(@mock_image).not_to receive(:reprocess!)
      subject.redo_watermark
    end
    it "should reprocess if there is no proecessing in progress" do
      expect(subject).to receive(:is_reprocessing).and_return(false)
      expect(subject).to receive(:attribution_changed?).and_return(true)
      expect(@mock_image).to receive(:reprocess!)
      subject.redo_watermark
    end
  end

  describe "image_size" do
    before(:each) do
      @mock_image = double
      allow(subject).to receive_messages(:image => @mock_image)
    end
    it "should return the images size" do
      expect(@mock_image).to receive(:size).and_return(100)
      expect(subject.image_size).to eq(100)
    end
    it "should return 0 even if there is no image" do
      @mock_image = nil
      expect(subject.image_size).to eq(0)
    end
  end

  # TODO: auto-generated
  describe '.published' do # scope test
    it 'supports named scope published' do
      expect(described_class.limit(3).published).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.private_status' do # scope test
    it 'supports named scope private_status' do
      expect(described_class.limit(3).private_status).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.draft_status' do # scope test
    it 'supports named scope draft_status' do
      expect(described_class.limit(3).draft_status).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.by_user' do # scope test
    it 'supports named scope by_user' do
      expect(described_class.limit(3).by_user(FactoryBot.create(:user))).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.with_status' do # scope test
    it 'supports named scope with_status' do
      expect(described_class.limit(3).with_status).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.not_private' do # scope test
    it 'supports named scope not_private' do
      expect(described_class.limit(3).not_private).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.visible_to_user' do # scope test
    it 'supports named scope visible_to_user' do
      expect(described_class.limit(3).visible_to_user).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.visible_to_user_with_drafts' do # scope test
    it 'supports named scope visible_to_user_with_drafts' do
      expect(described_class.limit(3).visible_to_user_with_drafts).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.no_drafts' do # scope test
    it 'supports named scope no_drafts' do
      expect(described_class.limit(3).no_drafts).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.like' do # scope test
    it 'supports named scope like' do
      expect(described_class.limit(3).like('x')).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.ordered_by' do # scope test
    it 'supports named scope ordered_by' do
      expect(described_class.limit(3).ordered_by(nil)).to all(be_a(described_class))
    end
  end

  # TODO: auto-generated
  describe '.can_be_created_by?' do
    xit 'can_be_created_by?' do
      user = FactoryBot.create(:user)
      result = described_class.can_be_created_by?(user)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.search_list' do
    it 'search_list' do
      options = {}
      result = described_class.search_list(options)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#check_image_presence' do
    it 'check_image_presence' do
      image = described_class.new
      result = image.check_image_presence

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#display_name' do
    it 'display_name' do
      image = described_class.new
      result = image.display_name

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#clean_image_filename' do
    xit 'clean_image_filename' do
      image = described_class.new
      result = image.clean_image_filename

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#save_image_dimensions' do
    it 'save_image_dimensions' do
      image = described_class.new
      result = image.save_image_dimensions

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#redo_watermark' do
    it 'redo_watermark' do
      image = described_class.new
      result = image.redo_watermark

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#clear_flags' do
    it 'clear_flags' do
      image = described_class.new
      result = image.clear_flags

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#dimensions' do
    it 'dimensions' do
      image = described_class.new
      result = image.dimensions

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#image_size' do
    it 'image_size' do
      image = described_class.new
      result = image.image_size

      expect(result).not_to be_nil
    end
  end

  describe '#image.url' do
    it 'is the missing image when not initialized' do
      image = described_class.new
      result = image.image.url
      expect(result).to eq("/images/original/missing.png")
    end
  end

  describe "when s3 is configured" do
    # These tests are useful to confirm that the gems are configured correctly to work
    # with paper clip. There paperclip requires aws-sdk version one
    before(:each) do
      Paperclip::Attachment.default_options[:storage] = :s3
    end
    after(:each) do
      Paperclip::Attachment.default_options[:storage] = :filesystem
    end

    describe '#image.url' do
      it 'is the missing image when not initialized' do
        image = described_class.new
        result = image.image.url
        expect(result).to eq("/images/original/missing.png")
      end
    end
  end
end
