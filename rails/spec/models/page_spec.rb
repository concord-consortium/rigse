require File.expand_path('../../spec_helper', __FILE__)

describe Page do
  before(:each) do
    @valid_attributes = {
      :name => "first page",
      :description => "a description of the first page",
      :teacher_only => false
    }
  end

  it "should create a new instance given valid attributes" do
    Page.create!(@valid_attributes)
  end

  it 'has_many for all ALL_EMBEDDABLES' do
    expect(ALL_EMBEDDABLES.length).to be > 0
    p = Page.create!(@valid_attributes)
    ALL_EMBEDDABLES.each do |e|
      expect(p.respond_to?(e[/::(\w+)$/, 1].underscore.pluralize)).to be(true)
    end
  end

  # at one point page had a default value set for :position
  # but that messes up acts_as_list
  describe "ordering" do
    it "should put pages in order by creation time" do
      @page = Page.create!(:name => "Page", :description => "Page description")
      @page2 = Page.create!(:name => "Page2", :description => "Page2 description")
      @page.reload
      @page2.reload
      expect(@page.position).to eq(1)
      expect(@page2.position).to eq(2)
    end
  end

  # TODO: auto-generated
  describe '.like' do # scope test
    it 'supports named scope like' do
      expect(described_class.limit(3).like('name')).to all(be_a(described_class))
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
  describe '.cloneable_associations' do
    it 'cloneable_associations' do
      result = described_class.cloneable_associations

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
  describe '#page_number' do
    it 'page_number' do
      page = described_class.new
      result = page.page_number

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#find_section' do
    it 'find_section' do
      page = described_class.new
      result = page.find_section

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#find_activity' do
    it 'find_activity' do
      page = described_class.new
      result = page.find_activity

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#default_page_name' do
    it 'default_page_name' do
      page = described_class.new
      result = page.default_page_name

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#name' do
    it 'name' do
      page = described_class.new
      result = page.name

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add_embeddable' do
    it 'add_embeddable' do
      page = described_class.new
      embeddable = FactoryBot.create(:open_response)
      position = 1
      result = page.add_embeddable(embeddable, position)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add_element' do
    xit 'add_element' do
      page = described_class.new
      element = double('element')
      result = page.add_element(element)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#element_for' do
    xit 'element_for' do
      page = described_class.new
      component = double('component')
      result = page.element_for(component)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#parent' do
    it 'parent' do
      page = described_class.new
      result = page.parent

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#investigation' do
    it 'investigation' do
      page = described_class.new
      result = page.investigation

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#has_inner_page?' do
    it 'has_inner_page?' do
      page = described_class.new
      result = page.has_inner_page?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#children' do
    it 'children' do
      page = described_class.new
      result = page.children

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#duplicate' do
    it 'duplicate' do
      page = described_class.new
      result = page.duplicate

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#reportable_elements' do
    it 'reportable_elements' do
      page = described_class.new
      result = page.reportable_elements

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#print_listing' do
    it 'print_listing' do
      page = described_class.new
      result = page.print_listing

      expect(result).not_to be_nil
    end
  end


end
