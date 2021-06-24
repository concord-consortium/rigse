class SearchController < ApplicationController

  include RestrictedController

  # PUNDIT_CHECK_FILTERS
  before_action :teacher_only, :only => [:index, :show]

  protected

  def teacher_only
    if current_visitor.portal_student
      raise Pundit::NotAuthorizedError
    end
  end

  def check_if_teacher
    if current_visitor.portal_teacher.nil? && request.xhr?
      respond_to do |format|
        format.js { render :json => "Not Teacher",:status => 401 }
      end
    end
  end

  public

  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Search
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    # @searches = policy_scope(Search)

    if request.query_parameters.empty?
      flash.keep
      return redirect_to action: 'index', include_official: '1'
    end

    opts = params.merge(:user_id => current_visitor.id, :skip_search => true)
    begin
      @form_model = Search.new(opts)
    rescue => e
      ExceptionNotifier::Notifier.exception_notification(request.env, e).deliver
      render :search_unavailable
    end
  end

  def unauthorized_user
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Search
    # authorize @search
    # authorize Search, :new_or_create?
    # authorize @search, :update_edit_or_destroy?
    raise Pundit::NotAuthorizedError
  end

  def setup_material_type
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Search
    # authorize @search
    # authorize Search, :new_or_create?
    # authorize @search, :update_edit_or_destroy?
    @material_type = param_find(:material_types, (params[:method] == :get)) ||
      (current_settings.include_external_activities? ? ['investigation','activity','external_activity'] : ['investigation','activity'])
  end


end
