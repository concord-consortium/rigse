require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Student do
  before(:each) do
    @student = FactoryBot.create(:portal_student)
  end

  describe "when a clazz is added to a students list of clazzes" do
    it "the students clazz list increases by one if the student is not already enrolled in that class" do
      clazz = FactoryBot.create(:portal_clazz)
      expect(@student.clazzes).to be_empty
      @student.add_clazz(clazz)
      @student.reload
      expect(@student.clazzes).not_to be_empty
      expect(@student.clazzes).to include(clazz)
      expect(@student.clazzes.size).to eq(1)
    end

    it "the students clazz list should stay the same if the same clazz is added multiple times" do
      clazz = FactoryBot.create(:portal_clazz)
      expect(@student.clazzes).to be_empty
      @student.add_clazz(clazz)
      @student.add_clazz(clazz)
      @student.reload
      expect(@student.clazzes).not_to be_empty
      expect(@student.clazzes).to include(clazz)
      expect(@student.clazzes.size).to eq(1)
    end
  end

  it "should generate a user name by first initial and last name" do
    expect(Portal::Student.generate_user_login("test", "user")).to eq("tuser")

    first_name = "Nametest"
    last_name  = "Testuser"
    @student.user = FactoryBot.create(:user, {
      :first_name => first_name,
      :last_name => last_name,
      :login => Portal::Student.generate_user_login(first_name, last_name),
      :password => "password",
      :password_confirmation => "password",
      :email => "test@test.com"
    })
    expect(@student.user.login).to eq("ntestuser")
    expect(Portal::Student.generate_user_login(@student.first_name, @student.last_name)).to eq(@student.user.login + "1")
  end



  # TODO: auto-generated
  describe '.generate_user_email' do
    it 'generate_user_email' do
      result = described_class.generate_user_email

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.generate_user_login' do
    it 'generate_user_login' do
      first_name ='first_name'
      last_name = 'last_name'
      result = described_class.generate_user_login(first_name, last_name)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#status' do
    it 'status' do
      student = described_class.new
      offerings_updated_after = Time.now
      result = student.status(offerings_updated_after)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_report_permissions' do
    it 'update_report_permissions' do
      student = described_class.new
      permission_form = double('permission_form')
      result = student.update_report_permissions(permission_form)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#schools' do
    it 'schools' do
      student = described_class.new
      result = student.schools

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#school' do
    it 'school' do
      student = described_class.new
      result = student.school

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#has_teacher?' do
    it 'has_teacher?' do
      student = described_class.new
      teacher = double('teacher')
      result = student.has_teacher?(teacher)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#children' do
    it 'children' do
      student = described_class.new
      result = student.children

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#process_class_word' do
    it 'process_class_word' do
      student = described_class.new
      class_word = 'class_word'
      result = student.process_class_word(class_word)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#has_clazz?' do
    it 'has_clazz?' do
      student = described_class.new
      clazz = double('clazz')
      result = student.has_clazz?(clazz)

      expect(result).to be_nil
    end
  end

  describe "#move_student_and_return_config" do
    let!(:student) { FactoryBot.create(:full_portal_student) }
    let!(:clazz_1) { FactoryBot.create(:portal_clazz, class_hash: 'class1hash') }
    let!(:clazz_2) { FactoryBot.create(:portal_clazz, class_hash: 'class2hash') }
    let!(:runnable_a) { FactoryBot.create(:external_activity, name: 'Test Activity', tool_id: 'https://test.org') }
    let!(:offering_a) { FactoryBot.create(:portal_offering, {clazz: clazz_1, runnable: runnable_a}) }
    let!(:offering_b) { FactoryBot.create(:portal_offering, {clazz: clazz_2, runnable: runnable_a}) }
    let!(:learner) { FactoryBot.create(:portal_learner, offering: offering_a, student: student) }

    it "should return JSON" do
      json = student.move_student_and_return_config(clazz_2, clazz_1)
      expect(json).to include(
        new_context_id:"class2hash",
        old_context_id:"class1hash",
        platform_user_id:student.user_id.to_s,
        new_class_info_url: /^http.*\/classes\/[0-9]*$/,
        platform_id: /^http.*/,
        assignments:[{new_resource_link_id: offering_b.id.to_s, old_resource_link_id: offering_a.id.to_s, tool_id: ENV['TEMP_TOOL_ID']}]
      )

    end
  end

end
