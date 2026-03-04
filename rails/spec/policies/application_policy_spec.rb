# frozen_string_literal: false

require 'spec_helper'

RSpec.describe ApplicationPolicy do

  # TODO: auto-generated
  describe '#index?' do
    it 'index?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.index?

      expect(result).to be true
    end
  end

  # TODO: auto-generated
  describe '#show?' do
    it 'show?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.show?

      expect(result).to be true
    end
  end

  # TODO: auto-generated
  describe '#create?' do
    it 'create?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.create?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#new?' do
    it 'new?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.new?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update?' do
    it 'update?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.update?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#edit?' do
    it 'edit?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.edit?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#destroy?' do
    it 'destroy?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.destroy?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#scope' do
    xit 'scope' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.scope

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#new_or_create?' do
    it 'new_or_create?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.new_or_create?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_edit_or_destroy?' do
    it 'update_edit_or_destroy?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.update_edit_or_destroy?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#not_anonymous?' do
    it 'not_anonymous?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.not_anonymous?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#changeable?' do
    it 'changeable?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.changeable?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#project_admin?' do
    it 'project_admin?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.project_admin?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#manager?' do
    it 'manager?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.manager?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#admin_or_manager?' do
    it 'admin_or_manager?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.admin_or_manager?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#manager_or_researcher?' do
    it 'manager_or_researcher?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.manager_or_researcher?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#admin?' do
    it 'admin?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.admin?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#admin_or_project_admin?' do
    it 'admin_or_project_admin?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.admin_or_project_admin?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#manager_or_project_admin?' do
    it 'manager_or_project_admin?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.manager_or_project_admin?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#manager_or_researcher_or_project_researcher?' do
    it 'manager_or_researcher_or_project_researcher?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.manager_or_researcher_or_project_researcher?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#author?' do
    it 'author?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.author?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#student?' do
    it 'student?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.student?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#teacher?' do
    it 'teacher?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.teacher?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#has_roles?' do
    it 'has_roles?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      roles = double('roles')
      result = application_policy.has_roles?(*roles)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#owner?' do
    it 'owner?' do
      context = nil # double('context')
      record = nil
      application_policy = described_class.new(context, record)
      result = application_policy.owner?

      expect(result).to be_nil
    end
  end

end
