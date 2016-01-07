# Old materials (non-external activities and investigations) follow
# general rules defined in the material policy, but they can also
# be authored by regular users that have author role and edited by their owner.

module OldMaterialSharedPolicy
  include MaterialSharedPolicy

  def new_or_create?
    super || author?
  end

  def edit_settings?
    super || owner?
  end
end
