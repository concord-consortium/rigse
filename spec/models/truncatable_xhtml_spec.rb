# DEFAULT_TABLES = ["content", "prompt"]
# DEFAULT_REPLACEABLES=  [
#   /\s+style\s?=\s?"(.*?)"/,
#   /&nbsp;/
# ]

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TruncatableXhtml do

  before(:each) do
    @styled_content = "<p style=\"ANYTHING\">something styled</p>"
    @unstyled_content ="<p>something without a style= entity.</p>"
    @xhtml_to_be_fixed = Xhtml.create({
      :name => "xhtml",
      :content => @styled_content
    });
    @xhtml_not_to_be_fixed = Xhtml.create({
      :name => "xhtml",
      :content => @unstyled_content
    })
  end
  
  describe "truncate xhtml entities" do
    it "should truncate xhtml entities"
    it "should extract first text"
    it "should extract text from xhtml elements"
    it "should soft truncate"
  end
  
  describe "replace xhtml entities" do 
    it "should replace unwanted entities when present" do
      @xhtml_to_be_fixed.should respond_to(:replace_offensive_html)
      @xhtml_to_be_fixed.replace_offensive_html.content.should_not eql @styled_content
      @xhtml_to_be_fixed.replace_offensive_html.content.should eql "<p >something styled</p>"
    end
    it "should leave non offending xhtml alone" do
      @xhtml_not_to_be_fixed.should respond_to(:replace_offensive_html)
      @xhtml_not_to_be_fixed.replace_offensive_html.content.should eql @unstyled_content
    end
  end
end