class Portal::GenericBookmarkPolicy < ApplicationPolicy

    def index?
        is_class_owner
    end

    def add?
        is_class_owner
    end

    def add_padlet?
        is_class_owner
    end

    def is_class_owner
        user && record && record.clazz && record.clazz.is_teacher?(user)
    end

end
