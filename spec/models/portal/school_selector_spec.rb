
require File.expand_path('../../../spec_helper', __FILE__)

def new_selector(params)
  return Portal::SchoolSelector.new(params)
end

describe Portal::SchoolSelector do
  before(:each) do
    @adhoc = mock_model(Admin::Project,    {:allow_adhoc_schools => true })
    @no_adhoc = mock_model(Admin::Project, {:allow_adhoc_schools => false })
    Admin::Project.stub!(:default_project).and_return(@adhoc)
  end
  describe "when presented for the first time (no query params)" do
    it "needs a state" do
      new_selector({}).needs.should == :state
    end
    it "provides state options" do
      new_selector({}).choices[:state].should include "MA"
    end
  end

  describe "when the user has selected England as the country" do
    before(:each) do
      @selector = new_selector({:country => 'England'})
    end
    it "does not require state or district information" do
      @selector.needs.should_not == :country
      @selector.needs.should_not == :state
      @selector.needs.should_not == :district
    end
    it "provides a list of schools in England" do
      pending # how do we do this?
    end
  end

  describe "when the user has selected the USA as the country" do
    before(:each) do
      @district1 = Factory(:portal_district, {:state => "MA", :name => "no district"} )
      @district2 = Factory(:portal_district, {:state => "MA"} )
      @district3 = Factory(:portal_district, {:state => "NY"} )

      @school1   = Factory(:portal_school, {:district => @district1})
      @school2   = Factory(:portal_school, {:district => @district1})
      @school3   = Factory(:portal_school, {:district => @district2})

      @default_district = Factory(:portal_district,  {:state => nil} )
      Portal::District.stub!(:default).and_return(@default_district)
      @selector = new_selector({:country => Portal::SchoolSelector::USA})
    end
    it "no longer requires a country" do
      @selector.needs.should_not == :country
    end
    it "requires a state" do
      @selector.needs.should == :state
    end
    it "presents a list of available states" do
      @selector.choices[:state].should include "MA"
      @selector.choices[:state].should include "NY"
    end

    describe "when the user has selected Massachussetts as the state" do
      before(:each) do
        @selector = new_selector({:country => Portal::SchoolSelector::USA, :state => 'MA'})
      end

      it "still requires a district" do
        @selector.needs.should == :district
      end

      it "presents choices for the districts in Massachussetts" do
        @selector.choices[:district].map { |d| d[1] }.should     include @district1.id
        @selector.choices[:district].map { |d| d[1] }.should     include @district2.id
        @selector.choices[:district].map { |d| d[1] }.should_not include @district3.id
      end

      describe "when the user has picked the first district in Massachussetts" do
        before(:each) do
          @selector = new_selector({:country => Portal::SchoolSelector::USA, :state => 'MA', :district => @district1.id.to_s})
        end

        it "no longer requires a district" do
          @selector.needs.should_not == :district
        end

        it "should still reqruire a school" do
          @selector.needs.should == :school
        end

        it "presents a list of schools in Massachussetts in district1" do
          @selector.choices[:school].map { |s| s[1]}.should     include @school1.id
          @selector.choices[:school].map { |s| s[1]}.should     include @school2.id
          @selector.choices[:school].map { |s| s[1]}.should_not include @school3.id
        end
      end

      describe "when the teacher hasn't picked a school" do
        before(:each) do
          @selector = new_selector({
            :country => Portal::SchoolSelector::USA,
            :state => 'MA',
            :district => @district1.id.to_s
          })
        end
        it "should indicate the selection is not complete" do
          @selector.should_not be_valid
        end
      end

      describe "checking if teachers can add districts and schools" do
        describe "when the portal allows adhoc schools" do
          before(:each) do
            Admin::Project.stub!(:default_project).and_return(@adhoc)
            @selector = new_selector({
            :country => Portal::SchoolSelector::USA,
            :state => 'MA',
            :district => @district1.id.to_s
          })
          end
          it "should let teachers add new schools" do
            @selector.allow_teacher_creation.should be_true
          end
        end
        describe "when the portal doesnt adhoc schools" do
          before(:each) do
            Admin::Project.stub!(:default_project).and_return(@no_adhoc)
          end
          it "shouldn't let teachers add new district" do
            @selector.allow_teacher_creation(:district).should be_false
          end
        end
      end

      describe "picking a school" do
        describe "when the school exists" do
          before(:each) do
            @selector = new_selector({
              :country => Portal::SchoolSelector::USA,
              :state => 'MA',
              :district => @district1.id.to_s,
              :school => @school2.id.to_s
            })
          end
        end

        describe "when the school doesn't exist" do
          before(:each) do
            @params = {
              :country => Portal::SchoolSelector::USA,
              :state => 'MA',
              :district => @district1.id.to_s,
              :school_name => "a new school"
            }
          end

          describe "when the project lets teacher create new schools" do
            before(:each) do
              Admin::Project.stub!(:default_project).and_return(@adhoc)
              @selector = new_selector(@params)
            end
            it "should have a district" do
              @selector.district.should_not be_nil
            end
            it "should have a school (id) set" do
              @selector.school.should_not be_nil
              @selector.school.should be_a_kind_of Portal::School
            end
            it "should be comeplete" do
              @selector.should be_valid
            end
          end

          describe "when the project prevents teachers from creating new schools" do
            before(:each) do
              Admin::Project.stub!(:default_project).and_return(@no_adhoc)
              @selector = new_selector(@params)
            end
            it "should remove the invalid school" do
              @selector.school.should be_nil
            end
            it "should not be comeplete" do
              @selector.should_not be_valid
            end
          end

        end
      end
    end
  end

  describe "changing values" do
    before(:each) do
      @me_distict = Factory(:portal_district, :state=>'ME')
      @me_school  = Factory(:portal_school, :district => @me_distict)
      @previous_params = ['United States','ME',@me_distict.id.to_s,@me_school.id.to_s]
      @previous_attr = Base64.encode64(@previous_params.join("|"))
    end
    describe "changing the state" do
      before(:each) do
        @params = {
          :country       => 'United States',
          :state         => 'MA',
          :district      => @me_distict.id.to_s,
          :school        => @me_school.id.to_s,
          :previous_attr => @previous_attr
        }
        @selector = new_selector(@params)
      end
      it "sould invalidate the district" do
        @selector.state.should == 'MA'
      end
      it "should invalidate the district" do
        @selector.district.should be_nil
      end
      it "should invlidate the school" do
        @selector.school.should be_nil
      end
    end
    describe "changing the district" do
      before(:each) do
        @changed_district = Factory(:portal_district)
        @params = {
          :country       => 'United States',
          :state         => 'ME',
          :district      => @changed_district.id.to_s,
          :school        => @me_school.id.to_s,
          :previous_attr => @previous_attr
        }
        @selector = new_selector(@params)
      end
      it "the state should still be valid" do
        @selector.state.should == "ME"
      end

      it "the district should be changed" do
        @selector.district.should == @changed_district
      end
      it "should invlidate the school" do
        @selector.school.should be_nil
      end
    end
  end
end
