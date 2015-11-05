class MiscMetalController < ActionController::Metal
  def time
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize MiscMetal
    # authorize @misc_metal
    # authorize MiscMetal, :new_or_create?
    # authorize @misc_metal, :update_edit_or_destroy?
    self.status = 200
    self.content_type = 'text/plain'
    self.response_body = "#{((Time.now.to_f - Time.now.gmt_offset) * 1000).to_i}"
  end
end
