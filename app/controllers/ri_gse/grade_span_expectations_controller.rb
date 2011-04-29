class RiGse::GradeSpanExpectationsController < ApplicationController

  # PUT /RiGse/grade_span_expectations/reparse_gses
  def reparse_gses
    parser = Parser.new
    parser.process_rigse_data
    respond_to do |format|
      flash[:notice] = 'Grade Span RiGse::Expectation. data reparsed from original RI-GSE documents'
      format.html { redirect_to :action => 'index' }
      format.xml  { head :ok }
    end    
  end
  
  # GET /RiGse/grade_span_expectations
  # GET /RiGse/grade_span_expectations.xml
  def index
    # :include => [:expectations => [:expectation_indicators, :stem]]
    respond_to do |format|
      format.html do
        @search_string = params[:search]
        if params[:mine_only]
          @grade_span_expectations = RiGse::GradeSpanExpectation.search(params[:search], params[:page], self.current_user, [{:expectations => [:expectation_indicators, :expectation_stem]}])
        else
          @grade_span_expectations = RiGse::GradeSpanExpectation.search(params[:search], params[:page], nil)
        end
      end
      format.xml do
        @grade_span_expectations = RiGse::GradeSpanExpectation.find(:all)
        render :xml => @grade_span_expectations
      end
      format.pdf do
        @grade_span_expectations = RiGse::GradeSpanExpectation.find(:all)        
        @rendered_partial = render_to_string :partial => 'expectation_list.html.haml', 
          :locals => { :grade_span_expectations => @grade_span_expectations }
        @rendered_partial.gsub!(/&/, '&amp;')
        render :layout => false 
      end
    end
  end

  # POST /RiGse/grade_span_expectations/select_js
  def select_js
    if params[:grade_span_expectation]
      @selected_gse = RiGse::GradeSpanExpectation.find_by_id(params[:grade_span_expectation][:id])
      session[:gse_id] = @selected_gse.id
    else
      @selected_gse = RiGse::GradeSpanExpectation.find_by_id(session[:gse_id])
    end
    # remember the chosen domain and grade_span, it will probably continue.
    if grade_span = params[:grade_span]
      session[:grade_span] = grade_span
      domain_id = session[:domain_id]
    elsif params[:domain_id]
      domain_id = params[:domain_id].to_i
      session[:domain_id] = domain_id
      grade_span = session[:grade_span]
    else
      grade_span = session[:grade_span]
      domain_id = session[:domain_id]
    end
    # FIXME 
    # domains (as an associated model) are way too far away from a gse
    # I added some finder_sql to the domain model to make this faster
    domain = RiGse::Domain.find(domain_id)
    gses = domain.grade_span_expectations 
    @related_gses = gses.find_all { |gse| gse.grade_span == grade_span }
    if request.xhr?
      render :partial => 'select_js', :locals => { :related_gses => @related_gses, :gse => @selected_gse }
    else
      respond_to do |format|
        format.js { render :partial => 'select_js', :locals => { :grade_span_expectations => @grade_span_expectations, :selected_gse => @selected_gse } }
      end
    end
  end

  # GET /RiGse/grade_span_expectations/1/summary
  def summary
    @grade_span_expectation = RiGse::GradeSpanExpectation.find(params[:id])
    
    if request.xhr?
      render :partial => 'summary', :locals => { :grade_span_expectations => @grade_span_expectations, :grade_span_expectation =>  @grade_span_expectation }
    else
      respond_to do |format|
        format.js { render :partial => 'select_js', :locals => { :grade_span_expectations => @grade_span_expectations, :grade_span_expectation =>  @grade_span_expectation } }
      end
    end
  end

  # GET /RiGse/grade_span_expectations/1
  # GET /RiGse/grade_span_expectations/1.xml
  def show
    @grade_span_expectation = RiGse::GradeSpanExpectation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @grade_span_expectation }
    end
  end

  # GET /RiGse/investigations/1/print
  def print
    @grade_span_expectation = RiGse::GradeSpanExpectation.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "layouts/print" }
      format.xml  { render :xml => @investigation }
    end
  end

  # GET /RiGse/grade_span_expectations/new
  # GET /RiGse/grade_span_expectations/new.xml
  def new
    @grade_span_expectation = RiGse::GradeSpanExpectation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @grade_span_expectation }
    end
  end

  # GET /RiGse/grade_span_expectations/1/edit
  def edit
    @grade_span_expectation = RiGse::GradeSpanExpectation.find(params[:id])
  end

  # POST /RiGse/grade_span_expectations
  # POST /RiGse/grade_span_expectations.xml
  def create
    @grade_span_expectation = RiGse::GradeSpanExpectation.new(params[:grade_span_expectation])

    respond_to do |format|
      if @grade_span_expectation.save
        flash[:notice] = 'RiGse::GradeSpanExpectation.was successfully created.'
        format.html { redirect_to(@grade_span_expectation) }
        format.xml  { render :xml => @grade_span_expectation, :status => :created, :location => @grade_span_expectation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @grade_span_expectation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /RiGse/grade_span_expectations/1
  # PUT /RiGse/grade_span_expectations/1.xml
  def update
    @grade_span_expectation = RiGse::GradeSpanExpectation.find(params[:id])

    respond_to do |format|
      if @grade_span_expectation.update_attributes(params[:grade_span_expectation])
        flash[:notice] = 'RiGse::GradeSpanExpectation.was successfully updated.'
        format.html { redirect_to(@grade_span_expectation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @grade_span_expectation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /RiGse/grade_span_expectations/1
  # DELETE /RiGse/grade_span_expectations/1.xml
  def destroy
    @grade_span_expectation = RiGse::GradeSpanExpectation.find(params[:id])
    @grade_span_expectation.destroy

    respond_to do |format|
      format.html { redirect_to(grade_span_expectations_url) }
      format.xml  { head :ok }
    end
  end
end
