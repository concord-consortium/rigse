class InvestigationStepsController < ApplicationController



  
  # GET /investigation_steps
  # GET /investigation_steps.xml
  def index
    @investigation_steps = InvestigationSteps.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @investigation_steps }
    end
  end

  # GET /investigation_steps/1
  # GET /investigation_steps/1.xml
  def show
    @investigation_steps = InvestigationSteps.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @investigation_steps }
    end
  end

  # GET /investigation_steps/new
  # GET /investigation_steps/new.xml
  def new
    @investigation_steps = InvestigationSteps.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @investigation_steps }
    end
  end

  # GET /investigation_steps/1/edit
  def edit
    @investigation_steps = InvestigationSteps.find(params[:id])
  end

  # POST /investigation_steps
  # POST /investigation_steps.xml
  def create
    @investigation_steps = InvestigationSteps.new(params[:investigation_steps])

    respond_to do |format|
      if @investigation_steps.save
        flash[:notice] = 'InvestigationSteps was successfully created.'
        format.html { redirect_to(@investigation_steps) }
        format.xml  { render :xml => @investigation_steps, :status => :created, :location => @investigation_steps }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @investigation_steps.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /investigation_steps/1
  # PUT /investigation_steps/1.xml
  def update
    @investigation_steps = InvestigationSteps.find(params[:id])

    respond_to do |format|
      if @investigation_steps.update_attributes(params[:investigation_steps])
        flash[:notice] = 'InvestigationSteps was successfully updated.'
        format.html { redirect_to(@investigation_steps) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @investigation_steps.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /investigation_steps/1
  # DELETE /investigation_steps/1.xml
  def destroy
    @investigation_steps = InvestigationSteps.find(params[:id])
    @investigation_steps.destroy

    respond_to do |format|
      format.html { redirect_to(investigation_steps_url) }
      format.xml  { head :ok }
    end
  end
  


  ##
  ##
  ##
  def add_step
    @investigation= Investigation.find(params['investigation_id'])
    class_name = params['kind']
    step = nil
    
    case class_name
    when 'Xhtml'
      step = Xhtml.create(:name => "new XHTML")
      step.investigations << @investigation
      step.save
    when 'OpenResponse'
        step = MultipleChoice.create(:prompt => "new OpenResponse")
        step.investigations << @investigation
        step.save
    when 'MultipleChoice'
      step = MultipleChoice.create(:prompt => "new MultipleChoice")
      step.investigations << @investigation
      step.save
    end
   
    # new_contents = render_to_string :partial => "steps", :layout => false
    render :update do |page|
        page.replace_html "steps", :partial => "steps"
        page.visual_effect :highlight, 'steps'
      end
  end
  
  
  ##
  ##
  ##  
  def sort_steps
    puts params.inspect
    render :text => "ok"
  end
  
  
  ##
  ##
  ##  
  def show_step()
    @step = params['id']
    mode = params['mode'] || 'edit'
    type = act_step.step_type
    partial = "#{mode}_#{type.downcase}"
    html = "could not render partial (#{partial})"
    begin
      html = render_to_string :partial => partial  
    rescue => e
      html = "#{html} : #{e}"
    end
    render html
  end
  

  ##
  ##
  ##
  def save_step
    @step = InvestigationStep.find(params['step_id'])
    @actual_step = @step.step
    attribute_updates = params.reject{ |k,v| !(@actual_step.attributes.has_key? k)}
    @actual_step.update_attributes(attribute_updates)
    @actual_step.save
    render :update do |page|
       page.visual_effect :highlight, params['id']
     end
  end



  ##
  ##
  ##
  def delete_step
    @investigation= Investigation.find(params['investigation_id'])
    @steps = InvestigationStep.find(:all, :conditions => {
      :step_id => params['step_id'],
      :investigation_id => params['investigation_id']
    });
    @steps.each do |step|
      #TODO: we need to remove lots of depenedant items potentially, see :dependent, after_destroy, &etc.
      step.destroy
    end
   
   new_contents = render_to_string :partial => "steps", :layout => false
   render :update do |page|
       page.replace_html "steps", new_contents
       page.visual_effect :highlight, 'steps'
     end
  end
end
