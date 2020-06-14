# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Admin::Project, type: :model do
  let (:project) { FactoryBot.create(:project) }
  let (:user) { FactoryBot.create(:user) }
  let (:project_admin) { FactoryBot.create(:user) }
  let (:project_researcher) { FactoryBot.create(:user) }
  before(:each) do
    project_admin.add_role_for_project('admin', project)
    project_researcher.add_role_for_project('researcher', project)
  end

  describe '.project_admins' do
    it 'project_admins' do
      result = project.project_admins

      expect(result).not_to be_nil
    end
  end

  describe '.project_researchers' do
    it 'project_researchers' do
      result = project.project_researchers

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#changeable?' do
    it 'changeable?' do
      result = project.changeable?(user)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.all_sorted' do
    it 'all_sorted' do
      result = described_class.all_sorted

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.with_landing_pages' do
    it 'with_landing_pages' do
      result = described_class.with_landing_pages

      expect(result).not_to be_nil
    end
  end

end
