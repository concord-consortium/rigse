class ActivityStepsController < ApplicationController



  
  # GET /activity_steps
  # GET /activity_steps.xml
  def index
    @activity_steps = ActivitySteps.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activity_steps }
    end
  end

  # GET /activity_steps/1
  # GET /activity_steps/1.xml
  def show
    @activity_steps = ActivitySteps.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @activity_steps }
    end
  end

  # GET /activity_steps/new
  # GET /activity_steps/new.xml
  def new
    @activity_steps = ActivitySteps.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity_steps }
    end
  end

  # GET /activity_steps/1/edit
  def edit
    @activity_steps = ActivitySteps.find(params[:id])
  end

  # POST /activity_steps
  # POST /activity_steps.xml
  def create
    @activity_steps = ActivitySteps.new(params[:activity_steps])

    respond_to do |format|
      if @activity_steps.save
        flash[:notice] = 'ActivitySteps was successfully created.'
        format.html { redirect_to(@activity_steps) }
        format.xml  { render :xml => @activity_steps, :status => :created, :location => @activity_steps }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity_steps.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /activity_steps/1
  # PUT /activity_steps/1.xml
  def update
    @activity_steps = ActivitySteps.find(params[:id])

    respond_to do |format|
      if @activity_steps.update_attributes(params[:activity_steps])
        flash[:notice] = 'ActivitySteps was successfully updated.'
        format.html { redirect_to(@activity_steps) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity_steps.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /activity_steps/1
  # DELETE /activity_steps/1.xml
  def destroy
    @activity_steps = ActivitySteps.find(params[:id])
    @activity_steps.destroy

    respond_to do |format|
      format.html { redirect_to(activity_steps_url) }
      format.xml  { head :ok }
    end
  end
  


  ##
  ##
  ##
  def add_step
    @activity = Activity.find(params['activity_id'])
    class_name = params['kind']
    step = nil
    
    case class_name
    when 'Xhtml'
      step = Xhtml.create(:name => "new XHTML")
      step.activities << @activity
      step.save
    when 'OpenResponse'
        step = MultipleChoice.create(:prompt => "new OpenResponse")
        step.activities << @activity
        step.save
    when 'MultipleChoice'
      step = MultipleChoice.create(:prompt => "new MultipleChoice")
      step.activities << @activity
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
    @step = ActivityStep.find(params['step_id'])
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
    @activity = Activity.find(params['activity_id'])
    @steps = ActivityStep.find(:all, :conditions => {
      :step_id => params['step_id'],
      :activity_id => params['activity_id']
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
