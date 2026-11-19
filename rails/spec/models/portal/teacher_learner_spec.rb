require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Teacher, 'learner account' do
  let(:teacher_user) do
    FactoryBot.create(:confirmed_user, first_name: 'Jane', last_name: 'Doe',
                      asked_age: true, have_consent: true, of_consenting_age: false)
  end
  let!(:teacher) { FactoryBot.create(:portal_teacher, user: teacher_user) }

  describe '#find_or_create_teacher_learner!' do
    it 'creates exactly one learner account, linked to the teacher' do
      learner_user = nil
      expect {
        learner_user = teacher.find_or_create_teacher_learner!
      }.to change(User, :count).by(1).and change(Portal::Student, :count).by(1)

      student = learner_user.portal_student
      expect(student.is_teacher_learner).to be true
      expect(teacher.reload.teacher_learner).to eq(student)

      expect(learner_user.first_name).to eq('Jane')
      expect(learner_user.last_name).to eq('Doe')
      expect(learner_user.login).to eq('jdoe')
      expect(learner_user.email).to match(/\Ano-email-.+@concord\.org\z/)
      expect(learner_user.asked_age).to be true
      expect(learner_user.have_consent).to be true
      expect(learner_user.of_consenting_age).to be false
      expect(learner_user.require_password_reset).to be false
      expect(learner_user.confirmed?).to be true
      expect(learner_user.portal_teacher).to be_nil
    end

    it 'returns the same account on a second call and creates nothing' do
      first = teacher.find_or_create_teacher_learner!
      expect {
        expect(teacher.find_or_create_teacher_learner!).to eq(first)
      }.not_to change(User, :count)
      expect(Portal::Student.where(is_teacher_learner: true).count).to eq(1)
    end

    # A real two-thread test is not possible here: spec_helper_common.rb makes all threads
    # share one database connection, so two threads cannot hold separate row locks.
    it 'locks the teacher row before it checks the link' do
      calls = []
      allow(teacher).to receive(:lock!).and_wrap_original { |m, *args| calls << :lock; m.call(*args) }
      allow(teacher).to receive(:teacher_learner).and_wrap_original { |m, *args| calls << :check; m.call(*args) }
      teacher.find_or_create_teacher_learner!
      expect(calls.first(2)).to eq([:lock, :check])
    end

    it 'works for a teacher whose last name is longer than a login can be' do
      teacher_user.update!(last_name: 'L' * 45)
      learner_user = teacher.reload.find_or_create_teacher_learner!
      expect(learner_user.login.length).to eq(User::MAX_LOGIN_LENGTH)
    end

    it 'works when a disabled user owns the login it would generate' do
      login = Portal::Student.generate_user_login(teacher_user.first_name, teacher_user.last_name)
      FactoryBot.create(:confirmed_user, login: login).update_column(:state, 'disabled')
      learner_user = teacher.find_or_create_teacher_learner!
      expect(learner_user.login).not_to eq(login)
    end

    it 'saves nothing when creation fails' do
      allow(Portal::Student).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Portal::Student.new))
      expect {
        expect { teacher.find_or_create_teacher_learner! }.to raise_error(ActiveRecord::RecordInvalid)
      }.not_to change(User, :count)
      expect(teacher.reload.teacher_learner_id).to be_nil
    end
  end

  describe 'renaming the teacher' do
    it 'copies a new first or last name to the learner account' do
      learner_user = teacher.find_or_create_teacher_learner!

      teacher_user.reload.update!(first_name: 'Janet')
      expect(learner_user.reload.first_name).to eq('Janet')

      teacher_user.reload.update!(last_name: 'Roe')
      expect(learner_user.reload.last_name).to eq('Roe')
      expect(learner_user.first_name).to eq('Janet')
    end

    it 'does nothing for a teacher with no learner account' do
      expect { teacher_user.update!(first_name: 'Janet') }.not_to change(User, :count)
    end

    # See the note on the creation lock test above.
    it 'locks the teacher row before it checks the link' do
      teacher.find_or_create_teacher_learner!
      teacher_user.reload
      portal_teacher = teacher_user.portal_teacher
      calls = []
      allow(portal_teacher).to receive(:lock!).and_wrap_original { |m, *args| calls << :lock; m.call(*args) }
      allow(portal_teacher).to receive(:teacher_learner).and_wrap_original { |m, *args| calls << :check; m.call(*args) }
      teacher_user.update!(first_name: 'Janet')
      expect(calls.first(2)).to eq([:lock, :check])
    end
  end

  describe 'deleting' do
    it "destroys the learner account when the teacher's user is destroyed" do
      learner_user = teacher.find_or_create_teacher_learner!
      student_id = learner_user.portal_student.id

      teacher_user.reload.destroy

      expect(User.where(id: learner_user.id)).to be_empty
      expect(Portal::Student.where(id: student_id)).to be_empty
    end

    it "clears the teacher's link when the learner account's user is destroyed on its own" do
      learner_user = teacher.find_or_create_teacher_learner!

      User.find(learner_user.id).destroy

      expect(User.where(id: teacher_user.id)).to exist
      expect(teacher.reload.teacher_learner_id).to be_nil
      new_learner_user = teacher.find_or_create_teacher_learner!
      expect(new_learner_user.id).not_to eq(learner_user.id)
      expect(teacher.reload.teacher_learner.user).to eq(new_learner_user)
    end

    it 'destroys a learner account that was created after the teacher was loaded' do
      stale_teacher = Portal::Teacher.find(teacher.id)
      learner_user = Portal::Teacher.find(teacher.id).find_or_create_teacher_learner!
      student_id = learner_user.portal_student.id

      stale_teacher.destroy

      expect(User.where(id: learner_user.id)).to be_empty
      expect(Portal::Student.where(id: student_id)).to be_empty
    end

    it 'works for a teacher with no learner account' do
      expect { teacher_user.reload.destroy }.to change(User, :count).by(-1)
    end
  end
end
