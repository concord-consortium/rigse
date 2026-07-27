class PortalTokenClaims
  STANDARD_TTL = 3600

  def initialize(context)
    @context = context
  end

  def learner_claims(user, learner)
    offering = learner.offering
    {
      :domain => @context.root_url,
      :user_type => "learner",
      :user_id => @context.url_for(user),
      :learner_id => learner.id,
      :class_info_url => offering.clazz.class_info_url(@context.request.protocol, @context.request.host_with_port),
      :offering_id => offering.id
    }
  end

  def teacher_claims(user, teacher)
    {
      :domain => @context.root_url,
      :user_type => "teacher",
      :user_id => @context.url_for(user),
      :teacher_id => teacher.id
    }
  end

  def add_admin_claims(user, claims)
    claims[:admin] = user.has_role?('admin') ? 1 : -1
    claims[:project_admins] = []
    user.project_users.each do |p|
      claims[:project_admins].push(p.project_id) if p.is_admin
    end
  end

  def sign(user, claims)
    SignedJwt::create_portal_token(user, claims, STANDARD_TTL)
  end
end
