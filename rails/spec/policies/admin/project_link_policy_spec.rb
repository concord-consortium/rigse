# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Admin::ProjectLinkPolicy do

  before(:each) do
    @project_link1 = FactoryBot.create(:admin_project_link)
    @project_link2 = FactoryBot.create(:admin_project_link)
    @project_link3 = FactoryBot.create(:admin_project_link)
  end

  let(:user) { FactoryBot.create(:user) }
  let(:scope) { Pundit.policy_scope!(user, Admin::ProjectLink) }

  describe "Scope" do
    context 'normal user' do
      it 'does not allow access to any project_links' do
        expect(scope.to_a.length).to eq 0
      end
    end

    context 'project researcher' do
      before(:each) do
        @project = FactoryBot.create(:project)
        @project.links << @project_link1
        user.add_role_for_project('researcher', @project)
      end

      it 'does not allow access to any project_links' do
        expect(scope.to_a.length).to eq 0
      end
    end

    context 'project admin' do
      before(:each) do
        @project = FactoryBot.create(:project)
        @project.links << @project_link1
        user.add_role_for_project('admin', @project)
      end

      it 'allows access to project project_links' do
        expect(scope.to_a).to match_array([@project_link1])
      end
    end

    context 'admin user' do
      let(:user) { FactoryBot.generate(:admin_user) }
      it 'allows access to all project_links' do
        expect(scope.to_a).to match_array([@project_link1, @project_link2, @project_link3])
      end
    end
  end

  describe 'create' do
    let(:project_link_stubs) { {project: 'project' } }
    let(:proj_user) { FactoryBot.create(:user) }
    let(:project_link) { double('project_link', project_link_stubs) }

    context 'as project admin' do
      before(:each) do
        allow(proj_user).to receive(:is_project_admin?).and_return(true)
      end

      it 'should allow create' do
        expect(Admin::ProjectLinkPolicy.new(proj_user, project_link)).to permit(:create)
      end

      it 'should allow update' do
        expect(Admin::ProjectLinkPolicy.new(proj_user, project_link)).to permit(:update)
      end
    end

    context 'not as project admin' do
      before(:each) do
        allow(proj_user).to receive(:is_project_admin?).and_return(false)
      end

      it 'should not allow create' do
        expect(Admin::ProjectLinkPolicy.new(proj_user, project_link)).to_not permit(:create)
      end

      it 'should not allow update' do
        expect(Admin::ProjectLinkPolicy.new(proj_user, project_link)).to_not permit(:update)
      end
    end

  end
end

