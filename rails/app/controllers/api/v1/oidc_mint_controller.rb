class API::V1::OidcMintController < API::APIController

  skip_before_action :verify_authenticity_token
  before_action :require_api_user!
  before_action :require_token_minter!

  # POST /api/v1/jwt/oidc_mint
  def create
    result = ForwardedFirebaseToken.verify(params[:firebase_token])

    subject_user, claims = build_scoped_claims(result)
    return if performed?

    description = sanitized_description
    claims.merge!(
      :minted_via_oidc_client_id => oidc_client.id,
      :origin_offering_id => result.origin_offering.id,
      :origin_class_hash => result.origin_clazz.class_hash,
      :minted_for => description
    )
    builder.add_admin_claims(subject_user, claims)

    Rails.logger.info(
      "OidcMint: minted client=#{oidc_client.id} token_type=#{params[:token_type]} " \
      "subject=#{subject_user.id} origin_offering=#{result.origin_offering.id} " \
      "origin_class=#{result.origin_clazz.id} description=#{description}"
    )

    render status: 201, json: { token: builder.sign(subject_user, claims) }
  rescue ForwardedFirebaseToken::Invalid => e
    render_forwarded_invalid(e)
  end

  private

  def build_scoped_claims(result)
    case params[:token_type]
    when 'learner'
      subject = result.user
      learner = result.origin_offering.find_or_create_learner(result.user.portal_student)
      [subject, builder.learner_claims(subject, learner)]
    when 'teacher'
      teacher = resolve_teacher(result)
      return [nil, nil] unless teacher
      [teacher.user, builder.teacher_claims(teacher.user, teacher)]
    else
      error('token_type must be "learner" or "teacher"', 422)
      [nil, nil]
    end
  end

  def resolve_teacher(result)
    if params[:class_id].present?
      target = Portal::Clazz.find_by(id: params[:class_id])
      unless target
        error('The requested class was not found', 422)
        return nil
      end
      shared = result.origin_clazz.teachers.to_a & target.teachers.to_a
      teacher = least_privileged_teacher(shared)
      unless teacher
        error('No teacher is shared between the origin class and the requested class', 422)
        return nil
      end
      teacher
    else
      teacher = least_privileged_teacher(result.origin_clazz.teachers)
      unless teacher
        error('The origin class has no teacher', 422)
        return nil
      end
      teacher
    end
  end

  def least_privileged_teacher(teachers)
    candidates = teachers.select { |t| t.user }.sort_by(&:id)
    return nil if candidates.empty?
    candidates.reject { |t| elevated_user?(t.user) }.first || candidates.first
  end

  def elevated_user?(user)
    user.has_role?('admin', 'manager', 'researcher') ||
      user.is_project_admin? || user.is_project_researcher?
  end

  def sanitized_description
    cleaned = params[:description].to_s[0, 100].gsub(/[\r\n]/, ' ')
    cleaned.blank? ? '(none)' : cleaned
  end

  def render_forwarded_invalid(e)
    error("Forwarded Firebase token invalid: #{e.reason}", 422, { reason: e.reason })
  end

  def require_token_minter!
    unless request.env['portal.auth_strategy'] == 'oidc_bearer_token'
      return error('This endpoint requires OIDC authentication', 403)
    end
    unless oidc_client&.can_mint_scoped_tokens?
      return error('This OIDC client is not permitted to mint scoped tokens', 403)
    end
  end

  def oidc_client
    return @oidc_client if defined?(@oidc_client)
    details = request.env['portal.auth_details']
    @oidc_client = details && Admin::OidcClient.find_by(sub: details[:sub])
  end

  def builder
    @builder ||= PortalTokenClaims.new(self)
  end
end
