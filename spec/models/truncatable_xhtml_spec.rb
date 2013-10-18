# DEFAULT_TABLES = ["content", "prompt"]
# DEFAULT_REPLACEABLES=  [
#   /\s+style\s?=\s?"(.*?)"/,
#   /&nbsp;/
# ]

require File.expand_path('../../spec_helper', __FILE__)

describe TruncatableXhtml do

  before(:each) do
    @replacement_examples = {
      "<p style=\"ANYTHING\">something styled</p>" =>  "<p>something styled</p>",
      "Text with some badly formated breaks <br/> <br> <br>" => "Text with some badly formated breaks <br/> <br/> <br/>",
      "&nbsp;&nbsp;&nbsp;" => " "
    }
    @non_replacement_examples = [
      "<p> nothing wrong with this paragraph </p>",
      "<h1> this paragraph is fine</h1>",
      "<br/> These breaks are fine <br/>"
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
        xhtml.stub(:html_replacements).and_return(TruncatableXhtml::DEFAULT_REPLACEABLES)
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
        xhtml.stub(:html_replacements).and_return(TruncatableXhtml::DEFAULT_REPLACEABLES)
        xhtml.replace_offensive_html.content.should eql(content)
      end
    end
  end
end