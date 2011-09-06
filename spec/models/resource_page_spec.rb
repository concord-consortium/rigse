require File.expand_path('../../spec_helper', __FILE__)

describe ResourcePage do
  
  describe "being created" do
    before do
      Paperclip.options[:log] = false
      @resource_page = ResourcePage.new
    end
    
    it "should not be valid by default" do
      @resource_page.should_not be_valid
    end
    
    it "should require a user id and name" do
      %w( user_id name ).each do |attribute|      
        r = build_resource_page(attribute.to_sym => nil)
        r.should_not be_valid
        r.errors[attribute.to_sym].should_not be_nil
      end

      r = build_resource_page
      r.should be_valid
    end
    
    it "should be set to 'draft' status by default" do
      r = build_resource_page(:publication_status => nil)
      r.publication_status.should be_nil
      r.should be_valid
      r.publication_status.should == 'draft'
    end
  end
  
  
  describe "after creation" do
    before do 
      @resource_page = create_resource_page
      @attachment = File.new(::Rails.root.to_s + '/spec/fixtures/images/rails.png')
    end
    
    it "should allow a new file to be attached" do
      @resource_page.attached_files.size.should == 0
      @resource_page.has_attached_files?.should be_false
      @resource_page.new_attached_files = { 'name' => 'attachment 1', 'attachment' => @attachment }
      @resource_page.has_attached_files?.should be_true
      @resource_page.attached_files.size.should == 1
    end
    
    it "should allow multiple new files to be attached" do
      @resource_page.attached_files.size.should == 0
      @resource_page.has_attached_files?.should be_false
      @resource_page.new_attached_files = [
        { 'name' => 'attachment 1', 'attachment' => @attachment },
        { 'name' => 'attachment 2', 'attachment' => @attachment },
        { 'name' => 'attachment 3', 'attachment' => @attachment }
      ]
      @resource_page.has_attached_files?.should be_true
      @resource_page.attached_files.size.should == 3
    end
    
    it "should include draft flag when in draft or private mode" do
      %w(draft private).each do |status|
        @resource_page = create_resource_page(:publication_status => status)
        @resource_page.display_name.should == "[#{status.upcase}] #{@resource_page.name}"
      end
    end
  end

protected

  def build_resource_page(options = {})
    ResourcePage.new({
      :user_id => 1, 
      :name => 'Resource Page', 
      :publication_status => 'draft', 
      :description => 'Page description here' }.merge(options))
  end
  
  def create_resource_page(options = {})
    r = build_resource_page(options)
    r.save
    r
  end
end