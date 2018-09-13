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
        allow(Admin::Settings).to receive_messages(:teachers_can_author? => true)
        teacher = FactoryGirl.create(:portal_teacher)
        teacher.possibly_add_authoring_role
        expect(teacher.user).to have_role('author')
      end
    end

    describe "when the portal doesn't allow the teacher to author" do
      it "should not add the authoring role to teachers when they are created" do
        allow(Admin::Settings).to receive_messages(:teachers_can_author? => false)
        teacher = FactoryGirl.create(:portal_teacher)
        teacher.possibly_add_authoring_role
        expect(teacher.user).not_to have_role('author')
      end
    end
  end

  describe '[default cohort support]' do
    let(:settings) { FactoryGirl.create(:admin_settings) }
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
      let(:cohort) { FactoryGirl.create(:admin_cohort) }
      let(:settings) { FactoryGirl.create(:admin_settings, default_cohort: cohort) }

      it 'is added to the default cohort' do
        expect(teacher.cohorts.length).to eql(1)
        expect(teacher.cohorts[0]).to eql(cohort)
      end
    end
  end



  # TODO: auto-generated
  describe '.LEFT_PANE_ITEM' do
    it 'LEFT_PANE_ITEM' do
      result = described_class.LEFT_PANE_ITEM

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.save_left_pane_submenu_item' do
    it 'save_left_pane_submenu_item' do
      current_visitor = User.new
      item_value = '1'
      result = described_class.save_left_pane_submenu_item(current_visitor, item_value)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '.can_author?' do
    it 'can_author?' do
      result = described_class.can_author?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.update_authoring_roles' do
    it 'update_authoring_roles' do
      result = described_class.update_authoring_roles

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#save_left_pane_submenu_item' do
    xit 'save_left_pane_submenu_item' do
      teacher = described_class.new
      item_value = '1'
      result = teacher.save_left_pane_submenu_item(item_value)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#name' do
    it 'name' do
      teacher = described_class.new
      result = teacher.name

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#list_name' do
    it 'list_name' do
      teacher = described_class.new
      result = teacher.list_name

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#school_ids' do
    it 'school_ids' do
      teacher = described_class.new
      result = teacher.school_ids

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#school_ids=' do
    xit 'school_ids=' do
      teacher = described_class.new
      ids = [1]
      result = teacher.school_ids=(ids)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#school_names' do
    it 'school_names' do
      teacher = described_class.new
      result = teacher.school_names

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#children' do
    it 'children' do
      teacher = described_class.new
      result = teacher.children

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#parent' do
    it 'parent' do
      teacher = described_class.new
      result = teacher.parent

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#students' do
    it 'students' do
      teacher = described_class.new
      result = teacher.students

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#has_clazz?' do
    it 'has_clazz?' do
      teacher = described_class.new
      clazz = nil
      result = teacher.has_clazz?(clazz)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#add_clazz' do
    xit 'add_clazz' do
      teacher = described_class.new
      clazz = nil
      result = teacher.add_clazz(clazz)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#remove_clazz' do
    xit 'remove_clazz' do
      teacher = described_class.new
      clazz = nil
      result = teacher.remove_clazz(clazz)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#school' do
    it 'school' do
      teacher = described_class.new
      result = teacher.school

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#possibly_add_authoring_role' do
    it 'possibly_add_authoring_role' do
      teacher = described_class.new
      result = teacher.possibly_add_authoring_role

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#my_classes_url' do
    xit 'my_classes_url' do
      teacher = described_class.new
      protocol = double('protocol')
      host = double('host')
      result = teacher.my_classes_url(protocol, host)

      expect(result).not_to be_nil
    end
  end


end
