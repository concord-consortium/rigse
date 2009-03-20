class PagesController < ApplicationController
  
  # GET /page
  # GET /page.xml
  def index
    # @investigation = Investigation.find(params['section_id'])
    # @pages = @investigation.pages
    @pages = Page.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /page/1
  # GET /page/1.xml
  def show
    @page = Page.find(params[:id], :include => :page_elements)
    @section = @page.section
    @page_elements = @page.page_elements
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /page/new
  # GET /page/new.xml
  def new
    @page = Page.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /page/1/edit
  def edit
    @page = Page.find(params[:id], :include => :page_elements)
    @page_elements = @page.page_elements
  end

  # POST /page
  # POST /page.xml
  def create
    respond_to do |format|
      if @page.save
        flash[:notice] = 'PageEmbedables was successfully created.'
        format.html { redirect_to(@page) }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /page/1
  # PUT /page/1.xml
  def update
    @page = Page.find(params[:id], :include => :page_elements)
    @page_elements = @page.page_elements
    respond_to do |format|
      if @page.update_attributes(params[:page])
        flash[:notice] = 'PageEmbedables was successfully updated.'
        format.html { redirect_to(@page) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /page/1
  # DELETE /page/1.xml
  def destroy
    @page = Page.find(params[:id], :include => :page_elements)
    @page_elements = @page.page_elements
    @page.destroy
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
    @page = Page.find(params[:id], :include => :page_elements)
    @page.page_elements.each do |element|
      element.position = params['page-element-list'].index(element.id.to_s) + 1
      element.save
    end 
    render :nothing => true
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
