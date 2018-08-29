require File.expand_path('../../spec_helper', __FILE__)

describe Interactive do
  let(:valid_attributes) { {
      :name => "Interactive 1",
      :description => "description of Interactive 1",
      :url => "http://lab.concord.org/embeddable.html#interactives/itsi/energy2d/conduction-wood-metal.json",
      :width => "690",
      :height => "400",
      :scale => "1.0",
      :image_url => "http://itsisu.concord.org/share/model_images/10.png",
      :user_id => "1",
      :credits => "credits of Interactive 1",
      :publication_status => "published"
    } }

  it "should create a new instance given valid attributes" do
    Interactive.create!(valid_attributes)
  end


  # TODO: auto-generated
  describe '.published' do # scope test
    it 'supports named scope published' do
      expect(described_class.limit(3).published).to all(be_a(described_class))
    end
  end

  # TODO: auto-generated
  describe '#is_official' do
    it 'is_official' do
      interactive = described_class.new
      result = interactive.is_official

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#teacher_only?' do
    it 'teacher_only?' do
      interactive = described_class.new
      result = interactive.teacher_only?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#display_name' do
    it 'display_name' do
      interactive = described_class.new
      result = interactive.display_name

      expect(result).to be_nil
    end
  end


end
