class InvestigationPolicy < ApplicationPolicy

  def printable_index?
    true
  end

  def preview_index?
    true
  end

  def teacher?
    true
  end

  def duplicate?
    not_anonymous?
  end

  def gse_select?
    true
  end

  def add_activity?
    changeable?
  end

  def sort_activities?
    changeable?
  end

  def delete_activity?
    changeable?
  end

  def export?
    true
  end

  def paste_link?
    changeable?
  end

  def paste?
    changeable?
  end

  def usage_report?
    manager_or_researcher?
  end

  def details_report?
    manager_or_researcher?
  end

end
