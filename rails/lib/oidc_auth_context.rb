class OidcAuthContext
  def initialize(request_or_env)
    @env = request_or_env.respond_to?(:env) ? request_or_env.env : (request_or_env || {})
  end

  def client
    return @client if defined?(@client)
    id = @env['portal.auth_client_id']
    @client = id ? Admin::OidcClient.find_by(id: id) : nil
  end

  def acting_as_forwarded_user?
    !!@env['portal.forwarded_student']
  end

  def origin_offering_id
    @env['portal.origin_offering_id']
  end

  def origin_class_hash
    @env['portal.origin_class_hash']
  end

  def origin_offering
    return nil unless origin_offering_id
    @origin_offering ||= Portal::Offering.find_by(id: origin_offering_id)
  end

  def origin_clazz
    origin_offering&.clazz
  end

  def capability?(name)
    !!client&.capability?(name)
  end
end
