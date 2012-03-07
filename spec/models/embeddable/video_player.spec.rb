require File.expand_path('../../../spec_helper', __FILE__)

require 'webmock'
include WebMock::API

describe Embeddable::VideoPlayer do
  before(:all) do
    @small_video_url = "http://example.com/small_video.mpeg"
    @small_image_url = "http://example.com/small_image.jpg"
    @non_existant_video = "http://example.com/not_found.mpeg"
    @non_existant_image = "http://example.com/not_found.jpg"

    stub_request(:head, @small_video_url).to_return(:status => ["200", "OK"], :headers => {"Content-Type" => "video/flash", "Content-Length" => 100})
    stub_request(:head, @small_image_url).to_return(:status => ["200", "OK"], :headers => {"Content-Type" => "video/flash", "Content-Length" => 100})
    stub_request(:head, @non_existant_image).to_return( :status => ["404", "Not Found"])
    stub_request(:head, @non_existant_video).to_return( :status => ["404", "Not Found"])
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
      video_player.should be_valid
    end
    
    it "it should not create a new instance with bad image_url" do
      video_player = Embeddable::VideoPlayer.create(@bad_url_attributes)
      video_player.save
      video_player.should_not be_valid
    end
    
    it "it should create a new instance without a image_url" do
      video_player = Embeddable::VideoPlayer.create(@missing_url_attributes)
      video_player.save
      video_player.should be_valid
    end

    it "it should not create a new instance with a bad name" do
      video_player = Embeddable::VideoPlayer.create(@bad_name_attributes)
      video_player.save
      video_player.should_not be_valid
    end
  end
  
  describe "should let authors attach images" do
    before(:each) do
      @video_player = Embeddable::VideoPlayer.create!(@valid_attributes)
    end
    
    it "should have image methods" do
      @video_player.should respond_to(:image_url)
      @video_player.should respond_to(:image_url=)
      @video_player.should respond_to(:has_image?)
    end
    
    it "should not have an image at first" do
      @video_player.has_image?.should be false
      @video_player.image_url.should be nil
    end
    
    it "should accept valid image urls" do
      @video_player.image_url=@small_image_url
      @video_player.save.should be true
      @video_player.reload
      @video_player.image_url.should == @small_image_url
      @video_player.has_image?.should be true
    end
    
    it "should reject invalid image urls" do
      @video_player.image_url=@non_existant_image
      @video_player.save.should be false
      @video_player.reload
      @video_player.image_url.should be_nil
      @video_player.has_image?.should be false
    end
  end

end
