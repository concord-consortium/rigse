require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::District do
  before(:each) do
    @valid_attributes = {
        :name => "value for name",
        :description => "value for description",
    }
  end

  it "should create a new instance given valid attributes" do
    Portal::District.create!(@valid_attributes)
  end

  it "should support virtual districts with no NCSES data" do
    expect(Portal::District.create!(@valid_attributes)).to be_virtual
  end

  context '.find_or_create_using_nces_district' do
    it "can create districts from NCES district data " do
      nces_district = Factory(:portal_nces06_district)
      new_district = Portal::District.find_or_create_using_nces_district(nces_district)
      expect(new_district).not_to be_nil
      expect(new_district).to be_real # meaning has a real nces school
    end
  end


  describe "ways to find districts" do
    before(:each) do
      @woonsocket_district = Factory(:portal_nces06_district, {
          :STID => 39,
          :LSTATE => 'RI',
          :NAME => 'Woonsocket',
      })
      @district = Factory(:portal_district, {
          :nces_district_id => @woonsocket_district.id,
      })
    end

    describe "Given an NCES local district id that matches the STID field in an NCES district" do
      it "finds and returns the first district that is associated with the NCES district if one exists" do
        found = Portal::District.find_by_state_and_nces_local_id('RI', 39)
        expect(found).not_to be_nil
        expect(found).to eql(@district)
      end

      it "returns nil if there is no match" do
        found = Portal::District.find_by_state_and_nces_local_id('MA', 39)
        expect(found).to be_nil
      end
    end

    describe "Given a district name that matches the NAME field in an NCES district" do
      it "finds and return the first district that is associated with the NCES district or nil." do
        found = Portal::District.find_by_state_and_district_name('RI', "Woonsocket")
        expect(found).not_to be_nil
        expect(found).to eql(@district)
      end

      it "If the district is a 'real' district return the NCES local district id" do
        found = Portal::District.find_by_state_and_district_name('MA', "Woonsocket")
        expect(found).to be_nil
      end
    end
  end


  # TODO: auto-generated
  describe '.real' do # scope test
    it 'supports named scope real' do
      expect(described_class.limit(3).real).to all(be_a(described_class))
    end
  end
  
  # TODO: auto-generated
  describe '.virtual' do # scope test
    it 'supports named scope virtual' do
      Portal::District.create!(@valid_attributes)
      expect(described_class.limit(3).virtual).to all(be_a(described_class))
      expect(described_class.limit(3).virtual).to have(1).entry
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
  describe '.find_by_state_and_nces_local_id' do
    it 'find_by_state_and_nces_local_id' do
      state = ('state')
      local_id = 1
      result = described_class.find_by_state_and_nces_local_id(state, local_id)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '.find_by_state_and_district_name' do
    it 'find_by_state_and_district_name' do
      state = ('state')
      district_name = ('district_name')
      result = described_class.find_by_state_and_district_name(state, district_name)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '.default' do
    it 'default' do
      result = described_class.default

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.find_by_similar_or_new' do
    it 'find_by_similar_or_new' do
      attrs = {}
      username = ('username')
      result = described_class.find_by_similar_or_new(attrs, username)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.find_by_similar_name_or_new' do
    it 'find_by_similar_name_or_new' do
      name = ('name')
      username = ('username')
      result = described_class.find_by_similar_name_or_new(name, username)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#virtual?' do
    it 'virtual?' do
      district = described_class.new
      result = district.virtual?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#real?' do
    it 'real?' do
      district = described_class.new
      result = district.real?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#nces_local_id' do
    it 'nces_local_id' do
      district = described_class.new
      result = district.nces_local_id

      expect(result).to be_nil
    end
  end


end
