class SectionsController < ApplicationController
  
  before_filter :find_entities
  protected 
  
  def find_entities
    # @investigation = Investigation.find(params[:section_id])
    @section = Section.find(params[:id])
  end
  

  ##
  ##
  ##
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @section }
    end
  end

  ##
  ##
  ##
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @section }
    end
  end

  ##
  ##
  ##
  def new
    @section = Section.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @section }
    end
  end

  ##
  ##
  ##
  def edit

  end

  ##
  ##
  ##
  def create
    respond_to do |format|
      if @section.save
        flash[:notice] = 'Section was successfully created.'
        format.html { redirect_to(@section) }
        format.xml  { render :xml => @section, :status => :created, :location => @section }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
      end
    end
  end

  ##
  ##
  ##
  def update
    @section = Section.find(params[:id])
    respond_to do |format|
      if @section.update_attributes(params[:page])
        flash[:notice] = 'Section was successfully updated.'
        format.html { redirect_to(@section) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
      end
    end
  end

  ##
  ##
  ##
  def destroy
    @section = Section.find(params[:id])
    @section.destroy
    respond_to do |format|
      format.html { redirect_to(page_url) }
      format.xml  { head :ok }
    end
  end
  


  ##
  ##
  ##
  def add_element
    @investigation= Investigation.find(params['investigation_id'])
    class_name = params['kind']
    step = nil
    
    case class_name
    when 'Xhtml'
      step = Xhtml.create(:name => "new XHTML")
      step.pages << @investigation
      step.save
    when 'OpenResponse'
        step = MultipleChoice.create(:prompt => "new OpenResponse")
        step.pages << @investigation
        step.save
    when 'MultipleChoice'
      step = MultipleChoice.create(:prompt => "new MultipleChoice")
      step.pages << @investigation
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
  def sort_elements
    puts params.inspect
    render :text => "ok"
  end
  
  
  ##
  ##
  ##  
  def show_element()
    @step = params['id']
    mode = params['mode'] || 'edit'
    type = act_element.step_type
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
  def save_element
    @step = PageEmbedable.find(params['step_id'])
    @actual_element = @step.step
    attribute_updates = params.reject{ |k,v| !(@actual_element.attributes.has_key? k)}
    @actual_element.update_attributes(attribute_updates)
    @actual_element.save
    render :update do |page|
       page.visual_effect :highlight, params['id']
     end
  end


  ##
  ##
  ##
  def delete_element
    @investigation= Investigation.find(params['investigation_id'])
    @steps = PageEmbedable.find(:all, :conditions => {
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
