module Portal::ClazzesHelper
  def render_portal_clazz_partial(name, portal_clazz=@portal_clazz)
    render :partial => name, :locals => {:portal_clazz => portal_clazz}
  end
end