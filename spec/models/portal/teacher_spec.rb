require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Teacher do
  before(:each) do
    @nces_teacher = Factory(:nces_portal_teacher)
    @virtual_teacher = Factory(:portal_teacher)
    @virtual_teacher.clazzes << Factory(:portal_clazz)
  end
  
  it "should support nces teachers" do
    expect(@nces_teacher).not_to be_nil
  end
  
  it "nces teachers should have at least one class" do
    expect(@nces_teacher.clazzes).not_to be_nil
    @nces_teacher.clazzes.size > 0
  end
  
  it "nces teachers class should be 'real'" do 
    expect(@nces_teacher.clazzes[0]).to be_real
  end
  
  it "virtual teachers should have virtual classes" do
    expect(@virtual_teacher.clazzes[0]).to be_virtual
  end
  
  # new policy: Teachers CAN change their real clazzes
  # TODO: If we want to lock classes we need to implement a different mechanism
  it "teachers with real clazzes should be able to change them" do
    expect(@nces_teacher.clazzes[0]).to be_changeable(@nces_teacher)
  end
  
  it "should support virtual teachers" do
    expect(@virtual_teacher).not_to be_nil
  end
  
  it "virtual teachers can have classes" do
    expect(@virtual_teacher.clazzes).not_to be_nil
    expect(@virtual_teacher.clazzes.size).not_to be(0)
  end
  
  it "virtual teachers class should not be real" do 
    expect(@virtual_teacher.clazzes[0].real?).not_to be_truthy
    expect(@virtual_teacher.clazzes[0].virtual?).to be_truthy
  end
  
  it "Teachers in virtual schools should be able to change their clazzes" do
    expect(@virtual_teacher.clazzes[0]).to be_changeable(@virtual_teacher)
  end

  # Should we enforce the school requirement via a validation, or should it be done in the controller at registration? -- Cantina-CMH 6/9/10
  # it "should not allow a teacher to exist without a school" do
  #   @virtual_teacher.should be_valid
  #   @virtual_teacher.schools = []
  #   @virtual_teacher.should_not be_valid
  #   
  #   @nces_teacher.should be_valid
  #   @nces_teacher.schools = []
  #   @nces_teacher.should_not be_valid
  # end

  describe "possibly_add_authoring_role" do
    describe "when the portal allows teachers to author" do
      it "should add the authoring role to teachers when they are created" do
        Admin::Settings.stub(:teachers_can_author? => true)
        teacher = Factory.create(:portal_teacher)
        teacher.possibly_add_authoring_role
        expect(teacher.user).to have_role('author')
      end
    end

    describe "when the portal doesn't allow the teacher to author" do
      it "should not add the authoring role to teachers when they are created" do
        Admin::Settings.stub(:teachers_can_author? => false)
        teacher = Factory.create(:portal_teacher)
        teacher.possibly_add_authoring_role
        expect(teacher.user).not_to have_role('author')
      end
    end
  end

  describe '[default cohort support]' do
    let(:settings) { Factory.create(:admin_settings) }
    let(:teacher) { Factory(:portal_teacher) }
    before(:each) do
      allow(Admin::Settings).to receive(:default_settings).and_return(settings)
    end

    describe 'when default cohort is not specified in portal settings' do
      it 'has empty list of cohorts' do
        expect(teacher.cohorts.length).to eql(0)
      end
    end

    describe 'when default cohort is specified in portal settings' do
      let(:cohort) { Factory.create(:admin_cohort) }
      let(:settings) { Factory.create(:admin_settings, default_cohort: cohort) }

      it 'is added to the default cohort' do
        expect(teacher.cohorts.length).to eql(1)
        expect(teacher.cohorts[0]).to eql(cohort)
      end
    end
  end

end
