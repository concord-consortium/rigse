class InvestigationsController < ApplicationController
  # GET /investigations
  # GET /investigations.xml
  
  prawnto :prawn=>{
    :page_layout=>:landscape,
  }
  
  before_filter :setup_object, :except => [:index, :add_step]
  
  protected
  
  def setup_object
    if params[:id]
      if params[:id].length == 36
        @investigation = Investigation.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @investigation = Investigation.find(params[:id])
      end
    elsif params[:investigation]
      @investigation = Investigation.new(params[:investigation])
    else
      @investigation = Investigation.new
    end
  end
  
  public
  
  def index
    # @investigations = Investigation.find(:all)
    @investigations = Investigation.search(params[:search], params[:page], self.current_user)
    @paginated_objects = @investigations
    

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @investigations }
    end
  end

  # GET /investigations/1
  # GET /investigations/1.xml
  def show
    @investigation = Investigation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @investigation }
      format.pdf {render :layout => false }
    end
  end

  # GET /investigations/new
  # GET /investigations/new.xml
  def new
    @investigation = Investigation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @investigation }
    end
  end

  # GET /investigations/1/edit
  def edit
    @investigation = Investigation.find(params[:id])
  end

  # POST /investigations
  # POST /investigations.xml
  def create
    @investigation = Investigation.new(params[:investigation])

    respond_to do |format|
      if @investigation.save
        flash[:notice] = 'Investigation was successfully created.'
        format.html { redirect_to(@investigation) }
        format.xml  { render :xml => @investigation, :status => :created, :location => @investigation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @investigation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /investigations/1
  # PUT /investigations/1.xml
  def update
    @investigation = Investigation.find(params[:id])

    respond_to do |format|
      if @investigation.update_attributes(params[:investigation])
        flash[:notice] = 'Investigation was successfully updated.'
        format.html { redirect_to(@investigation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @investigation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /investigations/1
  # DELETE /investigations/1.xml
  def destroy
    @investigation = Investigation.find(params[:id])
    @investigation.destroy

    respond_to do |format|
      format.html { redirect_to(investigations_url) }
      format.xml  { head :ok }
    end
  end
  
  def add_step
    puts params.inspect
    # render :js => "alert('hello')"
    investigation_id = params['investigation_id']
    @investigation = Investigation.find(investigation_id)
    # weird!
    class_name = params['id']
    step = nil

    case class_name
    when 'Xhtml'
      step = Xhtml.create(:name => "new XHTML")
      step.activities << @investigation
      step.save
    when 'OpenResponse'
      step = MultipleChoice.create(:prompt => "new OpenResponse")
      step.activities << @investigation
      step.save
    when 'MultipleChoice'
      step = MultipleChoice.create(:prompt => "new MultipleChoice")
      step.activities << @investigation
      step.save
    end

    new_contents = render_to_string :partial => "steps", :layout => false
    render :update do |page|
      page.replace_html "contents", new_contents
      page.visual_effect :highlight, 'contents'

    end
  end

end
