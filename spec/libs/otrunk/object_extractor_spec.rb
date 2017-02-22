require File.expand_path('../../../spec_helper', __FILE__)

describe Otrunk::ObjectExtractor do
  it "requires a otrunk element with an id" do
    Otrunk::ObjectExtractor.new("<otrunk id='test_id'></otrunk>")
  end
  
  describe "#find_all" do
    before(:each) do
      @extractor = Otrunk::ObjectExtractor.new <<-OTML
        <otrunk id='test_id'>
          <OTText text="hello 1"/>
          <OTBlah />
          <OTText text="hello 2"/>
        </otrunk>
      OTML
    end

    it "finds all elements of a type" do
      elements = @extractor.find_all("OTText")
      expect(elements.size).to eq(2)
    end
  
    it "finds no elements when type doesn't exist" do
      elements = @extractor.find_all("OTObject")
      expect(elements.size).to eq(0)
    end

    it "iterates elements of a type" do
      count = 0
      @extractor.find_all("OTText") do
        count += 1
      end
      expect(count).to eq(2)
    end

    it "iterates no elements when type doesn't exist" do
      count = 0
      @extractor.find_all("OTObject") do
        count += 1
      end
      expect(count).to eq(0)
    end
  end
  
  describe "the returned element of find_all" do
    before(:each) do
      @extractor = Otrunk::ObjectExtractor.new <<-OTML
        <otrunk id='test_id'>
          <OTTChoice>
            <currentChoices>
              <string>answer 1</string>
              <string>answer 2</string>
            </currentChoices>
          </OTChoice>
        </otrunk>
      OTML
    end
    
    it "handles the children method" do
      @extractor.find_all('currentChoices') do |choice|
        expect(choice.children).not_to be_nil
      end
    end
    
    it "children handle the elem? method" do
      count = 0
      @extractor.find_all('currentChoices') do |choice|
        choice.children.each do |child| 
          count += 1 if child.elem?
        end
      end
      expect(count).to eq(2)
    end
  end
  
  describe "#get_text_property" do
    it "returns the text of attributes" do
      @extractor = Otrunk::ObjectExtractor.new <<-OTML
        <otrunk id='test_id'>
          <OTText text="hello world"/>
        </otrunk>
      OTML
      
      @extractor.find_all("OTText") do |element|
        expect(@extractor.get_text_property(element, "text")).to eq('hello world')
      end
    end

    it "returns the text of child elements" do
      @extractor = Otrunk::ObjectExtractor.new <<-OTML
        <otrunk id='test_id'>
          <OTText>
            <text>hello world</text>
          </OTText>
        </otrunk>
      OTML
      
      @extractor.find_all("OTText") do |element|
        expect(@extractor.get_text_property(element, "text")).to eq('hello world')
      end
    end

    it "returns '' when not found" do
      @extractor = Otrunk::ObjectExtractor.new <<-OTML
        <otrunk id='test_id'>
          <OTText/>
        </otrunk>
      OTML
      
      @extractor.find_all("OTText") do |element|
        expect(@extractor.get_text_property(element, "text")).to eq('')
      end
    end
    
    it "returns '' when text element is empty" do
      @extractor = Otrunk::ObjectExtractor.new <<-OTML
        <otrunk id='test_id'>
          <OTText>
            <text></text>
          </OTText>
        </otrunk>
      OTML
      
      @extractor.find_all("OTText") do |element|
        expect(@extractor.get_text_property(element, "text")).to eq('')
      end
    end

    it "only finds the first child text" do
      # note this is not valid otml but this is how it worked with hpricot
      @extractor = Otrunk::ObjectExtractor.new <<-OTML
        <otrunk id='test_id'>
          <OTText>
            <text>hello world</text>
            <text>good bye</text>
          </OTText>
        </otrunk>
      OTML
      
      @extractor.find_all("OTText") do |element|
        expect(@extractor.get_text_property(element, "text")).to eq('hello world')
      end
    end

    it "only finds direct children" do
      # note: this is not a real OTrunk object but there a possibilities like this
      @extractor = Otrunk::ObjectExtractor.new <<-OTML
        <otrunk id='test_id'>
          <OTText>
            <text>some other text</text>
          </OTText>
          <OTQuestion>
            <prompt>
              <OTPrompt>
                <text>Why?</text>
              </OTPrompt>
            </prompt>
            <text>hello world</text>
          </OTQuestion>
        </otrunk>
      OTML
      
      @extractor.find_all("OTQuestion") do |element|
        expect(@extractor.get_text_property(element, "text")).to eq('hello world')
      end
    end
  end
  
  describe "#get_property_path" do
    it "returns value of attribute in an array" do
      # note: this is not a real OTrunk object but there a possibilities like this
      @extractor = Otrunk::ObjectExtractor.new <<-OTML
        <otrunk id='test_id'>
          <OTText text="hello world"/>
        </otrunk>
      OTML

      @extractor.find_all("OTText") do |element|
        expect(@extractor.get_property_path(element, "text").first).to eq('hello world')
      end
    end

    it "returns empty array when not found" do
      # note: this is not a real OTrunk object but there a possibilities like this
      @extractor = Otrunk::ObjectExtractor.new <<-OTML
        <otrunk id='test_id'>
          <OTText text="hello world"/>
        </otrunk>
      OTML

      @extractor.find_all("OTText") do |element|
        expect(@extractor.get_property_path(element, "blah").size).to eq(0)
      end
    end

    it "traverses elements and returns value of attribute in an array" do
      # note: this is not a real OTrunk object but there a possibilities like this
      @extractor = Otrunk::ObjectExtractor.new <<-OTML
        <otrunk id='test_id'>
          <OTObject>
            <child>
              <OTText text="hello world"/>
            </child>
          </OTObject>
        </otrunk>
      OTML

      @extractor.find_all("OTObject") do |element|
        expect(@extractor.get_property_path(element, "child/text").first).to eq('hello world')
      end
    end

    it "returns multiple results" do
      # note: this is not a real OTrunk object but there a possibilities like this
      @extractor = Otrunk::ObjectExtractor.new <<-OTML
        <otrunk id='test_id'>
          <OTObject>
            <child>
              <OTText text="hello world"/>
              <OTText text="this is some"/>
              <OTText text="text for answers"/>
            </child>
          </OTObject>
        </otrunk>
      OTML

      element = @extractor.find_all("OTObject").first
      texts = @extractor.get_property_path(element, "child/text")
      expect(texts.size).to eq(3)
      expect(texts[0]).to eq('hello world')
      expect(texts[1]).to eq('this is some')
      expect(texts[2]).to eq('text for answers')
    end

    it "returns multiple results (complex)" do
      # note: this is not a real OTrunk object but there a possibilities like this
      @extractor = Otrunk::ObjectExtractor.new <<-OTML
        <otrunk id='test_id'>
          <OTObject>
            <child>
              <OTHolder>
                <first>
                  <OTImage>
                    <src>First Source</src>
                  </OTImage>
                </first>
                <second>
                  <OTBlob>
                    <src>Second Source</src>
                  </OTBlob>
                </second>
                <third>
                  <OTOrange src="Third Source" />
                </third>
              </OTHolder>
            </child>
            <parent>
              <OTDisplay src="Display Source" />
            </parent>
          </OTObject>
        </otrunk>
      OTML

      element = @extractor.find_all("OTObject").first
      texts = @extractor.get_property_path(element, "child/*/src")
      expect(texts.size).to eq(3)
      expect(texts[0].to_s).to eq('First Source')
      expect(texts[1].to_s).to eq('Second Source')
      expect(texts[2].to_s).to eq('Third Source')
    end

  end
end
