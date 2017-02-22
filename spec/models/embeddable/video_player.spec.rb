require File.expand_path('../../../spec_helper', __FILE__)

require 'fakeweb'

describe Embeddable::VideoPlayer do
  before(:all) do
    @small_video_url = "http://example.com/small_video.mpeg"
    @small_image_url = "http://example.com/small_image.jpg"
    @non_existant_video = "http://example.com/not_found.mpeg"
    @non_existant_image = "http://example.com/not_found.jpg"

    FakeWeb.register_uri(:head, @small_video_url, :status => ["200", "OK"],:content_type => "video/flash", :content_length => 100)
    FakeWeb.register_uri(:head, @small_image_url, :status => ["200", "OK"],:content_type => "video/flash", :content_length => 100)
    FakeWeb.register_uri(:head, @non_existant_image, :status => ["404", "Not Found"])
    FakeWeb.register_uri(:head, @non_existant_video, :status => ["404", "Not Found"])
  end

  before(:each) do
    @valid_attributes={
      :video_url => @small_video_url,
      :name => "required name field",
    }
    @bad_url_attributes = {
      :video_url => @non_existant_video,
      :name => "required name"
    }
    @missing_url_attributes = {
      :video_url => "",
      :name => "required name"
    }
    
    @bad_name_attributes = {
      :video_url => @small_video_url,
      :name => ""
    }
  end

  describe "field validations" do
    it "should create a new instance given valid attributes" do
      video_player = Embeddable::VideoPlayer.create(@valid_attributes)
      video_player.save 
      expect(video_player).to be_valid
    end
    
    it "it should not create a new instance with bad image_url" do
      video_player = Embeddable::VideoPlayer.create(@bad_url_attributes)
      video_player.save
      expect(video_player).not_to be_valid
    end
    
    it "it should create a new instance without a image_url" do
      video_player = Embeddable::VideoPlayer.create(@missing_url_attributes)
      video_player.save
      expect(video_player).to be_valid
    end

    it "it should not create a new instance with a bad name" do
      video_player = Embeddable::VideoPlayer.create(@bad_name_attributes)
      video_player.save
      expect(video_player).not_to be_valid
    end
  end
  
  describe "should let authors attach images" do
    before(:each) do
      @video_player = Embeddable::VideoPlayer.create!(@valid_attributes)
    end
    
    it "should have image methods" do
      expect(@video_player).to respond_to(:image_url)
      expect(@video_player).to respond_to(:image_url=)
      expect(@video_player).to respond_to(:has_image?)
    end
    
    it "should not have an image at first" do
      expect(@video_player.has_image?).to be false
      expect(@video_player.image_url).to be nil
    end
    
    it "should accept valid image urls" do
      @video_player.image_url=@small_image_url
      expect(@video_player.save).to be true
      @video_player.reload
      expect(@video_player.image_url).to eq(@small_image_url)
      expect(@video_player.has_image?).to be true
    end
    
    it "should reject invalid image urls" do
      @video_player.image_url=@non_existant_image
      expect(@video_player.save).to be false
      @video_player.reload
      expect(@video_player.image_url).to be_nil
      expect(@video_player.has_image?).to be false
    end
  end

end
