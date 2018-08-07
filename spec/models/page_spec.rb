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

  it 'has an ordered list of embeddables' do
    Page.class_variables.include?(:@@element_types) &&
    Page.class_eval("@@element_types").first.kind_of?(String) &&
    Page.class_eval("@@element_types").first.match(/Embeddable/)
  end

  it 'has_many for all ALL_EMBEDDABLES' do
    expect(ALL_EMBEDDABLES.length).to be > 0
    p = Page.create!(@valid_attributes)
    ALL_EMBEDDABLES.each do |e|
      expect(p.respond_to?(e[/::(\w+)$/, 1].underscore.pluralize)).to be(true)
    end
  end

  it 'returns a list of embeddable class names' do
    Page.element_types.first.kind_of?(Class)
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
end
