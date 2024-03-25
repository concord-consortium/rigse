# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Admin::ProjectPolicy do

  # TODO: auto-generated
  describe '#index?' do
    it 'index?' do
      project_policy = described_class.new(nil, nil)
      result = project_policy.index?

      expect(result).to be_nil
    end
  end

  describe '#update_edit_or_destroy?' do
    it 'update_edit_or_destroy?' do
      project_policy = described_class.new(nil, nil)
      result = project_policy.update_edit_or_destroy?

      expect(result).to be_falsey
    end
  end

  # TODO: auto-generated
  describe '#not_anonymous?' do
    it 'not_anonymous?' do
      project_policy = described_class.new(nil, nil)
      result = project_policy.not_anonymous?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#visible?' do
    xit 'visible?' do
      project_policy = described_class.new(nil, nil)
      result = project_policy.visible?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#assign_to_material?' do
    it 'assign_to_material?' do
      project_policy = described_class.new(nil, nil)
      result = project_policy.assign_to_material?

      expect(result).to be_nil
    end
  end

  describe 'CRUD capabilities' do
    let(:user) { FactoryBot.create(:user)}
    let(:project) { FactoryBot.create(:project) }
    let(:policy) { described_class.new(user, project) }

    describe 'destroy' do
      describe 'a regular user' do
        it 'should not permit destroy' do
          expect(policy.destroy?).to be_falsey
        end
      end

      describe 'as site admin' do
        before(:each) do
          allow(user).to receive(:has_role?).with('admin').and_return(true)
        end
        it 'should permit destroy' do
          expect(policy.destroy?).to be true
        end
      end

      #TODO: We used to allow project admins to delete projects.
      # This seemed bad to me, so this is a change:
      describe 'as a project admin' do
        before(:each) do
          allow(user).to receive(:is_project_admin?).with(project).and_return(true)
        end
        it 'should permit destroy' do
          expect(policy.destroy?).to be false
        end
      end
    end

    describe 'new' do
      describe 'a regular user' do
        it 'should not permit new' do
          expect(policy.new?).to be false
        end
      end

      describe 'as site admin' do
        before(:each) do
          allow(user).to receive(:has_role?).with('admin').and_return(true)
        end
        it 'should permit new' do
          expect(policy.new?).to be true
        end
      end

      describe 'as a project admin' do
        before(:each) do
          allow(user).to receive(:is_project_admin?).with(project).and_return(true)
        end
        it 'should not permit new' do
          expect(policy.new?).to be false
        end
      end
    end

    describe 'create' do
      describe 'a regular user' do
        it 'should not permit create' do
          expect(policy.create?).to be false
        end
      end

      describe 'as site admin' do
        before(:each) do
          allow(user).to receive(:has_role?).with('admin').and_return(true)
        end
        it 'should permit create' do
          expect(policy.create?).to be true
        end
      end

      describe 'as a project admin' do
        before(:each) do
          allow(user).to receive(:is_project_admin?).with(project).and_return(true)
        end
        it 'should not permit create' do
          expect(policy.create?).to be false
        end
      end
    end


    describe 'edit' do
      describe 'a regular user' do
        it 'should not permit edit' do
          expect(policy.edit?).to be false
        end
      end

      describe 'as site admin' do
        before(:each) do
          allow(user).to receive(:has_role?).with('admin').and_return(true)
        end
        it 'should permit edit' do
          expect(policy.edit?).to be true
        end
      end

      describe 'as a project admin' do
        before(:each) do
          allow(user).to receive(:is_project_admin?).with(project).and_return(true)
        end
        it 'should permit edit' do
          expect(policy.edit?).to be true
        end
      end
    end

    describe 'update' do
      describe 'a regular user' do
        it 'should not permit update' do
          expect(policy.update?).to be false
        end
      end

      describe 'as site admin' do
        before(:each) do
          allow(user).to receive(:has_role?).with('admin').and_return(true)
        end
        it 'should permit update' do
          expect(policy.update?).to be true
        end
      end

      describe 'as a project admin' do
        before(:each) do
          allow(user).to receive(:is_project_admin?).with(project).and_return(true)
        end
        it 'should permit update' do
          expect(policy.update?).to be true
        end
      end
    end

    describe 'classes' do
      describe 'a regular user' do
        it 'should not permit access to classes page' do
          expect(policy.classes?).to be false
        end
      end

      describe 'as site admin' do
        before(:each) do
          allow(user).to receive(:has_role?).with('admin').and_return(true)
        end
        it 'should permit access to classses page' do
          expect(policy.classes?).to be true
        end
      end

      describe 'as a project admin' do
        before(:each) do
          allow(user).to receive(:is_project_admin?).with(project).and_return(true)
        end
        it 'should permit access to classses page' do
          expect(policy.classes?).to be true
        end
      end

      describe 'as a project researcher' do
        before(:each) do
          allow(user).to receive(:is_project_researcher?).with(project).and_return(true)
        end
        it 'should permit access to classses page' do
          expect(policy.research_classes?).to be true
        end
      end
    end
  end
end
