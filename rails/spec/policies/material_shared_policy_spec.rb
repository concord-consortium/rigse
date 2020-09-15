# frozen_string_literal: false

require 'spec_helper'

RSpec.describe MaterialSharedPolicy do

  let(:material_shared_policy) { InteractivePolicy.new(nil, nil) }

  # TODO: auto-generated
  describe '#new_or_create?' do
    it 'new_or_create?' do

      result = material_shared_policy.new_or_create?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#edit_settings?' do
    it 'edit_settings?' do

      result = material_shared_policy.edit_settings?

      expect(result).to be false
    end
  end

  # TODO: auto-generated
  describe '#edit_credits?' do
    it 'edit_credits?' do

      result = material_shared_policy.edit_credits?

      expect(result).to be false
    end
  end

  # TODO: auto-generated
  describe '#edit_projects?' do
    it 'edit_projects?' do

      result = material_shared_policy.edit_projects?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#edit_cohorts?' do
    it 'edit_cohorts?' do

      result = material_shared_policy.edit_cohorts?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#edit_publication_status?' do
    it 'edit_publication_status?' do

      result = material_shared_policy.edit_publication_status?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#edit_grade_levels?' do
    it 'edit_grade_levels?' do

      result = material_shared_policy.edit_grade_levels?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#edit_subject_areas?' do
    it 'edit_subject_areas?' do

      result = material_shared_policy.edit_subject_areas?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#edit_sensors?' do
    it 'edit_sensors?' do

      result = material_shared_policy.edit_sensors?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#edit_standards?' do
    it 'edit_standards?' do

      result = material_shared_policy.edit_standards?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#edit?' do
    it 'edit?' do

      result = material_shared_policy.edit?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update?' do
    it 'update?' do

      result = material_shared_policy.update?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#destroy?' do
    it 'destroy?' do

      result = material_shared_policy.destroy?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#material_admin?' do
    it 'material_admin?' do

      result = material_shared_policy.material_admin?

      expect(result).to be false
    end
  end

  # TODO: auto-generated
  describe '#admin_or_material_admin?' do
    it 'admin_or_material_admin?' do

      result = material_shared_policy.admin_or_material_admin?

      expect(result).to be false
    end
  end

  # TODO: auto-generated
  describe '#visible?' do
    xit 'visible?' do

      result = material_shared_policy.visible?

      expect(result).to be_nil
    end
  end

end
