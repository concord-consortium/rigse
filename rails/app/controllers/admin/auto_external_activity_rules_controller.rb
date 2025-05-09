class Admin::AutoExternalActivityRulesController < ApplicationController
  before_action :set_auto_external_activity_rule, only: %i[ show edit update destroy ]
  before_action :set_authors

  # GET /auto_external_activity_rules
  def index
    @auto_external_activity_rules = Admin::AutoExternalActivityRule.all
  end

  # GET /auto_external_activity_rules/1
  def show
  end

  # GET /auto_external_activity_rules/new
  def new
    @auto_external_activity_rule = Admin::AutoExternalActivityRule.new
  end

  # GET /auto_external_activity_rules/1/edit
  def edit
  end

  # POST /auto_external_activity_rules
  def create
    @auto_external_activity_rule = Admin::AutoExternalActivityRule.new(auto_external_activity_rule_params)

    if params[:update_external_reports]
      @auto_external_activity_rule.external_report_ids= (params[:external_reports] || [])
    end

    if @auto_external_activity_rule.save
      redirect_to @auto_external_activity_rule, notice: "Auto external activity rule was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /auto_external_activity_rules/1
  def update
    if @auto_external_activity_rule.update(auto_external_activity_rule_params)
      if params[:update_external_reports]
        @auto_external_activity_rule.external_report_ids= (params[:external_reports] || [])
        @auto_external_activity_rule.save
      end

      redirect_to @auto_external_activity_rule, notice: "Auto external activity rule was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /auto_external_activity_rules/1
  def destroy
    @auto_external_activity_rule.destroy!
    redirect_to admin_auto_external_activity_rules_path, notice: "Auto external activity rule was successfully destroyed.", status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_auto_external_activity_rule
    @auto_external_activity_rule = Admin::AutoExternalActivityRule.find(params.expect(:id))
  end

  def set_authors
    @authors = User.with_role("author").order([:first_name, :last_name])
  end

  # Only allow a list of trusted parameters through.
  def auto_external_activity_rule_params
    params.expect(admin_auto_external_activity_rule: [ :name, :slug, :description, :allow_patterns, :user_id, :external_reports ])
  end
end
