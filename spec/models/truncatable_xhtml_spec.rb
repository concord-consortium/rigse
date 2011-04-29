# DEFAULT_TABLES = ["content", "prompt"]
# DEFAULT_REPLACEABLES=  [
#   /\s+style\s?=\s?"(.*?)"/,
#   /&nbsp;/
# ]

require 'spec_helper'

describe TruncatableXhtml do

  before(:each) do
    @replacement_examples = {
      "<p style=\"ANYTHING\">something styled</p>" =>  "<p>something styled</p>",
      "&nbsp;&nbsp;&nbsp;" => " "
    }
    @non_replacement_examples = [
      "<p> nothing wrong with this paragraph </p>",
      "<h1> this paragraph is fine</h1>" 
    ]
  end
  
  describe "truncate xhtml entities" do
    it "should truncate xhtml entities"
    it "should extract first text"
    it "should extract text from xhtml elements"
    it "should soft truncate"
  end
  
  describe "replace xhtml entities" do 
    it "should replace unwanted entities when present" do
      @replacement_examples.each_pair do |original, expected|
        xhtml = Embeddable::Xhtml.create({
         :name =>"testing",
         :content => original
        })
        xhtml.replace_offensive_html.content.should_not eql(original)
        xhtml.replace_offensive_html.content.should eql(expected)
      end
    end
    it "should leave non offending xhtml alone" do
      @non_replacement_examples.each do |content|
        xhtml = Embeddable::Xhtml.create({
         :name => "testing",
         :content => content
        })
        xhtml.replace_offensive_html.content.should eql(content)
      end
    end
  end
end