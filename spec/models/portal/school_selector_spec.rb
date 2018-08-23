
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


  # TODO: auto-generated
  describe '.country_choices' do
    it 'country_choices' do
      result = described_class.country_choices

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#load_previous_attributes' do
    it 'load_previous_attributes' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.load_previous_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#record_previous_attributes' do
    it 'record_previous_attributes' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.record_previous_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#attr_changed?' do
    xit 'attr_changed?' do
      params = {}
      school_selector = described_class.new(params)
      symbol = 'symbol'
      result = school_selector.attr_changed?(symbol)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#get_attr' do
    it 'get_attr' do
      params = {}
      school_selector = described_class.new(params)
      attr = 'attr'
      result = school_selector.get_attr(attr)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#set_attr' do
    it 'set_attr' do
      params = {}
      school_selector = described_class.new(params)
      attr = 'attr'
      val = 'val'
      result = school_selector.set_attr(attr, val)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#clear_attr' do
    it 'clear_attr' do
      params = {}
      school_selector = described_class.new(params)
      attr = double('attr')
      result = school_selector.clear_attr(attr)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#clear_choices' do
    it 'clear_choices' do
      params = {}
      school_selector = described_class.new(params)
      attr = double('attr')
      result = school_selector.clear_choices(attr)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#validate' do
    xit 'validate' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.validate

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#invalid?' do
    it 'invalid?' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.invalid?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#valid?' do
    it 'valid?' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.valid?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#validate_attr' do
    xit 'validate_attr' do
      params = {}
      school_selector = described_class.new(params)
      symbol = 'Learner'
      result = school_selector.validate_attr(symbol)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#validate_country' do
    it 'validate_country' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.validate_country

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#validate_state' do
    it 'validate_state' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.validate_state

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#validate_district' do
    it 'validate_district' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.validate_district

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#validate_school' do
    it 'validate_school' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.validate_school

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#default_state_for' do
    it 'default_state_for' do
      params = {}
      school_selector = described_class.new(params)
      country = double('country')
      result = school_selector.default_state_for(country)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#default_district_for' do
    it 'default_district_for' do
      params = {}
      school_selector = described_class.new(params)
      state_or_country = double('state_or_country')
      result = school_selector.default_district_for(state_or_country)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add_district' do
    it 'add_district' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.add_district

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add_school' do
    it 'add_school' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.add_school

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add_portal_resource' do
    it 'add_portal_resource' do
      params = {}
      school_selector = described_class.new(params)
      symbol = 'Learner'
      result = school_selector.add_portal_resource(symbol)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#needs' do
    it 'needs' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.needs

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#choices' do
    it 'choices' do
      params = {}
      school_selector = described_class.new(params)
      symbol = double('symbol')
      result = school_selector.choices(symbol)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#country_choices' do
    it 'country_choices' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.country_choices

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#state_choices' do
    it 'state_choices' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.state_choices

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#district_choices' do
    it 'district_choices' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.district_choices

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#school_choices' do
    it 'school_choices' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.school_choices

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#select_args' do
    xit 'select_args' do
      params = {}
      school_selector = described_class.new(params)
      field = 'field'
      result = school_selector.select_args(field)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#attr_order' do
    it 'attr_order' do
      params = {}
      school_selector = described_class.new(params)
      result = school_selector.attr_order

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#allow_teacher_creation' do
    it 'allow_teacher_creation' do
      params = {}
      school_selector = described_class.new(params)
      field = double('field')
      result = school_selector.allow_teacher_creation(field)

      expect(result).not_to be_nil
    end
  end


end
