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
    
  it "can create districts from NCES district data " do
    nces_district = Factory(:portal_nces06_district)
    new_district = Portal::District.find_or_create_by_nces_district(nces_district)
    expect(new_district).not_to be_nil
    expect(new_district).to be_real # meaning has a real nces school
  end
  
  
  describe "ways to find districts" do
    before(:each) do
      @woonsocket_district = Factory(:portal_nces06_district, {
        :STID => 39,
        :LSTATE => 'RI',
        :NAME => 'Woonsocket',
      })
      @district = Factory(:portal_district,{
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
  
end
