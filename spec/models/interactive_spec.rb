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

end
