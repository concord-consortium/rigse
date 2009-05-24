class GradeSpanExpectationsController < ApplicationController

  # PUT /grade_span_expectations/reparse_gses
  def reparse_gses
    parser = Parser.new
    parser.process_rigse_data
    respond_to do |format|
      flash[:notice] = 'Grade Span Expectations data reparsed from original RI-GSE documents'
      format.html { redirect_to :action => 'index' }
      format.xml  { head :ok }
    end    
  end
  
  # GET /grade_span_expectations
  # GET /grade_span_expectations.xml
  def index
    @grade_span_expectations = GradeSpanExpectation.search(params[:search], params[:page], self.current_user, [{:expectations => [:expectation_indicators, :expectation_stem]}])
    # :include => [:expectations => [:expectation_indicators, :stem]]
    @search_string = params[:search]
    @paginated_objects = @grade_span_expectations

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @grade_span_expectations }
      format.pdf do
        @rendered_partial = render_to_string :partial => 'expectation_list.html.haml', 
          :locals => { :grade_span_expectations => @grade_span_expectations }
        @rendered_partial.gsub!(/&/, '&amp;')
        render :layout => false 
      end
    end
  end

  # POST /grade_span_expectations/select_js
  def select_js
    # remember the chosen domain and gradespan, it will probably continue..
    cookies[:gradespan] = params[:gradespan]
    cookies[:domain] = params[:domain]
    
    @grade_span_expectations = GradeSpanExpectation.find(:all, :include =>:knowledge_statements, :conditions => ['grade_span LIKE ?', params[:gradespan]])
    @grade_span_expectations = @grade_span_expectations.select do |gse|
      if gse.knowledge_statements.detect { |ks| 
        ks.domain_id == params[:domain].to_i 
        } 
        true
      else
        false
      end
    end
    if request.xhr?
      render :partial => 'select_js'
    else
      respond_to do |format|
        format.js
      end
    end
  end

  # GET /grade_span_expectations/1
  # GET /grade_span_expectations/1.xml
  def show
    @grade_span_expectation = GradeSpanExpectation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @grade_span_expectation }
    end
  end

  # GET /investigations/1/print
  def print
    @grade_span_expectation = GradeSpanExpectation.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "layouts/print" }
      format.xml  { render :xml => @investigation }
    end
  end

  # GET /grade_span_expectations/new
  # GET /grade_span_expectations/new.xml
  def new
    @grade_span_expectation = GradeSpanExpectation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @grade_span_expectation }
    end
  end

  # GET /grade_span_expectations/1/edit
  def edit
    @grade_span_expectation = GradeSpanExpectation.find(params[:id])
  end

  # POST /grade_span_expectations
  # POST /grade_span_expectations.xml
  def create
    @grade_span_expectation = GradeSpanExpectation.new(params[:grade_span_expectation])

    respond_to do |format|
      if @grade_span_expectation.save
        flash[:notice] = 'GradeSpanExpectation was successfully created.'
        format.html { redirect_to(@grade_span_expectation) }
        format.xml  { render :xml => @grade_span_expectation, :status => :created, :location => @grade_span_expectation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @grade_span_expectation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /grade_span_expectations/1
  # PUT /grade_span_expectations/1.xml
  def update
    @grade_span_expectation = GradeSpanExpectation.find(params[:id])

    respond_to do |format|
      if @grade_span_expectation.update_attributes(params[:grade_span_expectation])
        flash[:notice] = 'GradeSpanExpectation was successfully updated.'
        format.html { redirect_to(@grade_span_expectation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @grade_span_expectation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /grade_span_expectations/1
  # DELETE /grade_span_expectations/1.xml
  def destroy
    @grade_span_expectation = GradeSpanExpectation.find(params[:id])
    @grade_span_expectation.destroy

    respond_to do |format|
      format.html { redirect_to(grade_span_expectations_url) }
      format.xml  { head :ok }
    end
  end
end
