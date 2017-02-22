
require File.expand_path('../../../spec_helper', __FILE__)

def new_selector(params)
  return Portal::SchoolSelector.new(params)
end

describe Portal::SchoolSelector do
  before(:each) do
    @adhoc = mock_model(Admin::Settings,    {:allow_adhoc_schools => true })
    @no_adhoc = mock_model(Admin::Settings, {:allow_adhoc_schools => false })
    allow(Admin::Settings).to receive(:default_settings).and_return(@adhoc)
    @district1 = Factory(:portal_district, {:state => "MA", :name => "no district"} )
  end
  describe "when presented for the first time (no query params)" do
    it "needs a state" do
      expect(new_selector({}).needs).to eq(:state)
    end
    it "provides state options" do
      expect(new_selector({}).choices[:state]).to include "MA"
    end
  end

  describe "when the user has selected England as the country" do
    before(:each) do
      @selector = new_selector({:country => 'England'})
    end
    it "does not require state or district information" do
      expect(@selector.needs).not_to eq(:country)
      expect(@selector.needs).not_to eq(:state)
      expect(@selector.needs).not_to eq(:district)
    end
    it "provides a list of schools in England" do
      skip # how do we do this?
    end
  end

  describe "when the user has selected the USA as the country" do
    before(:each) do
      @district2 = Factory(:portal_district, {:state => "MA"} )
      @district3 = Factory(:portal_district, {:state => "NY"} )

      @school1   = Factory(:portal_school, {:district => @district1})
      @school2   = Factory(:portal_school, {:district => @district1})
      @school3   = Factory(:portal_school, {:district => @district2})

      @default_district = Factory(:portal_district,  {:state => nil} )
      allow(Portal::District).to receive(:default).and_return(@default_district)
      @selector = new_selector({:country => Portal::SchoolSelector::USA})
    end
    it "no longer requires a country" do
      expect(@selector.needs).not_to eq(:country)
    end
    it "requires a state" do
      expect(@selector.needs).to eq(:state)
    end
    it "presents a list of available states" do
      expect(@selector.choices[:state]).to include "MA"
      expect(@selector.choices[:state]).to include "NY"
    end

    describe "when the user has selected Massachussetts as the state" do
      before(:each) do
        @selector = new_selector({:country => Portal::SchoolSelector::USA, :state => 'MA'})
      end

      it "still requires a district" do
        expect(@selector.needs).to eq(:district)
      end

      it "presents choices for the districts in Massachussetts" do
        expect(@selector.choices[:district].map { |d| d[1] }).to     include @district1.id
        expect(@selector.choices[:district].map { |d| d[1] }).to     include @district2.id
        expect(@selector.choices[:district].map { |d| d[1] }).not_to include @district3.id
      end

      describe "when the user has picked the first district in Massachussetts" do
        before(:each) do
          @selector = new_selector({:country => Portal::SchoolSelector::USA, :state => 'MA', :district => @district1.id.to_s})
        end

        it "no longer requires a district" do
          expect(@selector.needs).not_to eq(:district)
        end

        it "should still reqruire a school" do
          expect(@selector.needs).to eq(:school)
        end

        it "presents a list of schools in Massachussetts in district1" do
          expect(@selector.choices[:school].map { |s| s[1]}).to     include @school1.id
          expect(@selector.choices[:school].map { |s| s[1]}).to     include @school2.id
          expect(@selector.choices[:school].map { |s| s[1]}).not_to include @school3.id
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
          expect(@selector).not_to be_valid
        end
      end

      describe "checking if teachers can add districts and schools" do
        describe "when the portal allows adhoc schools" do
          before(:each) do
            allow(Admin::Settings).to receive(:default_settings).and_return(@adhoc)
            @selector = new_selector({
            :country => Portal::SchoolSelector::USA,
            :state => 'MA',
            :district => @district1.id.to_s
          })
          end
          it "should let teachers add new schools" do
            expect(@selector.allow_teacher_creation).to be_truthy
          end
        end
        describe "when the portal doesnt adhoc schools" do
          before(:each) do
            allow(Admin::Settings).to receive(:default_settings).and_return(@no_adhoc)
          end
          it "shouldn't let teachers add new district" do
            expect(@selector.allow_teacher_creation(:district)).to be_falsey
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

          describe "when the settings lets teacher create new schools" do
            before(:each) do
              allow(Admin::Settings).to receive(:default_settings).and_return(@adhoc)
              @selector = new_selector(@params)
            end
            it "should have a district" do
              expect(@selector.district).not_to be_nil
            end
            it "should have a school (id) set" do
              expect(@selector.school).not_to be_nil
              expect(@selector.school).to be_a_kind_of Portal::School
            end
            it "should be comeplete" do
              expect(@selector).to be_valid
            end
          end

          describe "when the settings prevents teachers from creating new schools" do
            before(:each) do
              allow(Admin::Settings).to receive(:default_settings).and_return(@no_adhoc)
              @selector = new_selector(@params)
            end
            it "should remove the invalid school" do
              expect(@selector.school).to be_nil
            end
            it "should not be comeplete" do
              expect(@selector).not_to be_valid
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
        expect(@selector.state).to eq('MA')
      end
      it "should invalidate the district" do
        expect(@selector.district).to be_nil
      end
      it "should invlidate the school" do
        expect(@selector.school).to be_nil
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
        expect(@selector.state).to eq("ME")
      end

      it "the district should be changed" do
        expect(@selector.district).to eq(@changed_district)
      end
      it "should invlidate the school" do
        expect(@selector.school).to be_nil
      end
    end
  end
end
