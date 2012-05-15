class Embeddable::Biologica::PedigreesController < ApplicationController
  # GET /Embeddable::Biologica/biologica_pedigrees
  # GET /Embeddable::Biologica/biologica_pedigrees.xml
  def index    
    @biologica_pedigrees = Embeddable::Biologica::Pedigree.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @biologica_pedigrees}
    end
  end

  # GET /Embeddable::Biologica/biologica_pedigrees/1
  # GET /Embeddable::Biologica/biologica_pedigrees/1.xml
  def show
    @biologica_pedigree = Embeddable::Biologica::Pedigree.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :biologica_pedigree => @biologica_pedigree }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/embeddable/biologica/pedigree" } # biologica_pedigree.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @biologica_pedigree  }}
        format.config { render :partial => 'shared/show', :locals => { :runnable => @biologica_pedigree, :session_id => (params[:session] || request.env["rack.session.options"][:id])  } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @biologica_pedigree} }
        format.xml  { render :biologica_pedigree => @biologica_pedigree }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_pedigrees/new
  # GET /Embeddable::Biologica/biologica_pedigrees/new.xml
  def new
    @biologica_pedigree = Embeddable::Biologica::Pedigree.new
    modify_organism_ids
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_pedigree => @biologica_pedigree }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @biologica_pedigree }
      end
    end
  end

  # GET /Embeddable::Biologica/biologica_pedigrees/1/edit
  def edit
    @biologica_pedigree = Embeddable::Biologica::Pedigree.find(params[:id])
    @scope = get_scope(@biologica_pedigree)
    modify_organism_ids
    if request.xhr?
      render :partial => 'remote_form', :locals => { :biologica_pedigree => @biologica_pedigree }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @biologica_pedigree  }
      end
    end
  end
  

  # POST /Embeddable::Biologica/biologica_pedigrees
  # POST /Embeddable::Biologica/biologica_pedigrees.xml
  def create
    @biologica_pedigree = Embeddable::Biologica::Pedigree.new(params[:biologica_pedigree])
    cancel = params[:commit] == "Cancel"
    modify_organism_ids
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @biologica_pedigree.save
        render :partial => 'new', :locals => { :biologica_pedigree => @biologica_pedigree }
      else
        render :xml => @biologica_pedigree.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_pedigree.save
          flash[:notice] = 'Biologicapedigree was successfully created.'
          format.html { redirect_to(@biologica_pedigree) }
          format.xml  { render :xml => @biologica_pedigree, :status => :created, :location => @biologica_pedigree }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @biologica_pedigree.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable::Biologica/biologica_pedigrees/1
  # PUT /Embeddable::Biologica/biologica_pedigrees/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    modify_organism_ids
    @biologica_pedigree = Embeddable::Biologica::Pedigree.find(params[:id])
    if request.xhr?
      if cancel || @biologica_pedigree.update_attributes(params[:embeddable_biologica_pedigree])
        render :partial => 'show', :locals => { :biologica_pedigree => @biologica_pedigree }
      else
        render :xml => @biologica_pedigree.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @biologica_pedigree.update_attributes(params[:embeddable_biologica_pedigree])
          flash[:notice] = 'Biologicapedigree was successfully updated.'
          format.html { redirect_to(@biologica_pedigree) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @biologica_pedigree.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable::Biologica/biologica_pedigrees/1
  # DELETE /Embeddable::Biologica/biologica_pedigrees/1.xml
  def destroy
    @biologica_pedigree = Embeddable::Biologica::Pedigree.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(biologica_pedigrees_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @biologica_pedigree.page_elements.each do |pe|
      pe.destroy
    end
    @biologica_pedigree.destroy    
  end

  private

  # HACK: NP 2011-05
  # options_for_select is returning params like this:
  # "organism_ids"=>["796,797"] notice that the array
  # only has one string value(!) Can't figure out why.
  def modify_organism_ids
    return unless params[:embeddable_biologica_pedigree]
    value = params[:embeddable_biologica_pedigree][:organism_ids]    
    return if value.nil?
    case value
    when Array
      value.map! { |v| v.kind_of?(String) ? v.split(",") : v }
    when String
      value = value.split(",")
    end
    value = [value]
    params[:embeddable_biologica_pedigree][:organism_ids]=value.flatten.compact
  end 
end
