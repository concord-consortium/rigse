class Portal::OfferingsController < ApplicationController

  layout 'report', :only => %w{report open_response_report multiple_choice_report separated_report}
  include RestrictedPortalController
  before_filter :teacher_admin_or_config, :only => [:report, :open_response_report, :multiple_choice_report, :separated_report, :report_embeddable_filter]

  def current_clazz
    Portal::Offering.find(params[:id]).clazz
  end

  public

  # GET /portal_offerings
  # GET /portal_offerings.xml
  def index
    @portal_offerings = Portal::Offering.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_offerings }
    end
  end

  # GET /portal_offerings/1
  # GET /portal_offerings/1.xml
  def show
    @offering = Portal::Offering.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @offering }

      format.run_sparks_html   {
        if learner = setup_portal_student
          session[:put_path] = saveable_sparks_measuring_resistance_url(:format => :json)
        else
          session[:put_path] = nil
        end
        render 'page]/show', :layout => "layouts/run"
      }

      format.run_external_html   {
         if learner = setup_portal_student
           cookies[:save_path] = @offering.runnable.save_path
           cookies[:learner_id] = learner.id
           cookies[:student_name] = "#{current_user.first_name} #{current_user.last_name}"
           cookies[:activity_name] = @offering.runnable.name
           # session[:put_path] = saveable_sparks_measuring_resistance_url(:format => :json)
         else
           # session[:put_path] = nil
         end
         redirect_to(@offering.runnable.url, 'popup' => true)
       }

      format.jnlp {
        # check if the user is a student in this offering's class
        if learner = setup_portal_student
          if params.delete(:use_installer)
            wrapped_jnlp_url = polymorphic_url(@offering, :format => :jnlp, :params => params)
            render :partial => 'shared/learn_installer', :locals =>
              { :runnable => @offering.runnable, :learner => learner, :wrapped_jnlp_url => wrapped_jnlp_url }
          else
            render :partial => 'shared/learn', :locals => { :runnable => @offering.runnable, :learner => learner }
          end
        else
          # The current_user is a teacher (or another user acting like a teacher)
          if params.delete(:use_installer)
            wrapped_jnlp_url = polymorphic_url(@offering, :format => :jnlp, :params => params, :teacher_mode => true )
            render :partial => 'shared/show_installer', :locals =>
              { :runnable => @offering.runnable, :wrapped_jnlp_url => wrapped_jnlp_url, :teacher_mode => true }
          else
            render :partial => 'shared/show', :locals => { :runnable => @offering.runnable, :teacher_mode => true }
          end
        end
      }
    end
  end

  # GET /portal_offerings/new
  # GET /portal_offerings/new.xml
  def new
    @offering = Portal::Offering.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @offering }
    end
  end

  # GET /portal_offerings/1/edit
  def edit
    @offering = Portal::Offering.find(params[:id])
  end

  # POST /portal_offerings
  # POST /portal_offerings.xml
  def create
    @offering = Portal::Offering.new(params[:offering])

    respond_to do |format|
      if @offering.save
        flash[:notice] = 'Portal::Offering was successfully created.'
        format.html { redirect_to(@offering) }
        format.xml  { render :xml => @offering, :status => :created, :location => @offering }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @offering.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_offerings/1
  # PUT /portal_offerings/1.xml
  def update
    @offering = Portal::Offering.find(params[:id])

    respond_to do |format|
      if @offering.update_attributes(params[:offering])
        flash[:notice] = 'Portal::Offering was successfully updated.'
        format.html { redirect_to(@offering) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @offering.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_offerings/1
  # DELETE /portal_offerings/1.xml
  def destroy
    @offering = Portal::Offering.find(params[:id])
    @offering.destroy

    respond_to do |format|
      format.html { redirect_to(portal_offerings_url) }
      format.xml  { head :ok }
    end
  end

  def activate
    @offering = Portal::Offering.find(params[:id])
    @offering.activate!
    redirect_to :back
  end

  def deactivate
    @offering = Portal::Offering.find(params[:id])
    @offering.deactivate!
    redirect_to :back
  end

  def report
    @offering = Portal::Offering.find(params[:id])
    reportUtil = Report::Util.reload(@offering)  # force a reload of this offering
    @learners = reportUtil.learners

    @page_elements = reportUtil.page_elements

    respond_to do |format|
      format.html # report.html.haml
    end
  end

  def multiple_choice_report
    @offering = Portal::Offering.find(params[:id], :include => :learners)
    @offering_report = Report::Offering::Investigation.new(@offering)

    respond_to do |format|
      format.html # multiple_choice_report.html.haml
    end
  end

  def open_response_report
    @offering = Portal::Offering.find(params[:id], :include => :learners)
    @offering_report = Report::Offering::Investigation.new(@offering)

    respond_to do |format|
      format.html # open_response_report.html.haml
    end
  end

  def separated_report
    @offering = Portal::Offering.find(params[:id])
    reportUtil = Report::Util.reload(@offering)  # force a reload of this offering
    @learners = reportUtil.learners

    @page_elements = reportUtil.page_elements

    respond_to do |format|
      format.html # report.html.haml
    end
  end

  def report_embeddable_filter
    @offering = Portal::Offering.find(params[:id])
    @report_embeddable_filter = @offering.report_embeddable_filter

    if params[:commit] == "Show all"
      @report_embeddable_filter.ignore = true
    else
      @report_embeddable_filter.ignore = false
    end

    embeddables = params[:filter].collect{|type, ids|
      logger.info "processing #{type}: #{ids.inspect}"
      klass = type.constantize
      ids.collect{|id|
        klass.find(id.to_i)
      }
    }.flatten.compact.uniq
    @report_embeddable_filter.embeddables = embeddables

    redirect_url = report_portal_offering_url(@offering)
    respond_to do |format|
      if @report_embeddable_filter.save
        flash[:notice] = 'Report filter was successfully updated.'
        format.html { redirect_to :back }
        format.xml  { head :ok }
      else
        format.html { redirect_to :back }
        format.xml  { render :xml => @report_embeddable_filter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /portal/offerings/data_test(.format)
  def data_test
    clazz = Portal::Clazz::data_test_clazz
    @offering = clazz.offerings.first
    @user = current_user
    @student = @user.portal_student
    unless @student
      @student=Portal::Student.create(:user => @user)
    end
    @learner = @offering.find_or_create_learner(@student)
    respond_to do |format|
      format.html # views/portal/offerings/test.html.haml
      format.jnlp {
        render :partial => 'shared/learn', :locals => { :runnable => @offering.runnable, :learner => @learner, :data_test => true }
      }
    end
  end


  def setup_portal_student
    learner = nil
    if portal_student = current_user.portal_student
      # create a learner for the user if one doesnt' exist
      learner = @offering.find_or_create_learner(portal_student)
    end
    learner
  end
end
