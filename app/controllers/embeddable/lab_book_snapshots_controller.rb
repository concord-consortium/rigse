class Embeddable::LabBookSnapshotsController < ApplicationController
  # GET /Embeddable/lab_book_snapshots
  # GET /Embeddable/lab_book_snapshots.xml
  def index    
    @lab_book_snapshots = Embeddable::LabBookSnapshot.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lab_book_snapshots}
    end
  end

  # GET /Embeddable/lab_book_snapshots/1
  # GET /Embeddable/lab_book_snapshots/1.xml
  def show
    @lab_book_snapshot = Embeddable::LabBookSnapshot.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :lab_book_snapshot => @lab_book_snapshot }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/embeddable/lab_book_snapshot" } # lab_book_snapshot.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @lab_book_snapshot, :teacher_mode => false } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @lab_book_snapshot, :teacher_mode => false, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @lab_book_snapshot, :teacher_mode => false } }
        format.xml  { render :lab_book_snapshot => @lab_book_snapshot }
      end
    end
  end

  # GET /Embeddable/lab_book_snapshots/new
  # GET /Embeddable/lab_book_snapshots/new.xml
  def new
    @lab_book_snapshot = Embeddable::LabBookSnapshot.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :lab_book_snapshot => @lab_book_snapshot }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @lab_book_snapshot }
      end
    end
  end

  # GET /Embeddable/lab_book_snapshots/1/edit
  def edit
    @lab_book_snapshot = Embeddable::LabBookSnapshot.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :lab_book_snapshot => @lab_book_snapshot }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @lab_book_snapshot  }
      end
    end
  end
  

  # POST /Embeddable/lab_book_snapshots
  # POST /Embeddable/lab_book_snapshots.xml
  def create
    @lab_book_snapshot = Embeddable::LabBookSnapshot.new(params[:lab_book_snapshot])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @lab_book_snapshot.save
        render :partial => 'new', :locals => { :lab_book_snapshot => @lab_book_snapshot }
      else
        render :xml => @lab_book_snapshot.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @lab_book_snapshot.save
          flash[:notice] = 'Labbooksnapshot was successfully created.'
          format.html { redirect_to(@lab_book_snapshot) }
          format.xml  { render :xml => @lab_book_snapshot, :status => :created, :location => @lab_book_snapshot }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @lab_book_snapshot.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable/lab_book_snapshots/1
  # PUT /Embeddable/lab_book_snapshots/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @lab_book_snapshot = Embeddable::LabBookSnapshot.find(params[:id])
    if request.xhr?
      if cancel || @lab_book_snapshot.update_attributes(params[:embeddable_lab_book_snapshot])
        @lab_book_snapshot.save
        render :partial => 'show', :locals => { :lab_book_snapshot => @lab_book_snapshot }
      else
        render :xml => @lab_book_snapshot.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @lab_book_snapshot.update_attributes(params[:embeddable_lab_book_snapshot])
          flash[:notice] = 'Labbooksnapshot was successfully updated.'
          format.html { redirect_to(@lab_book_snapshot) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @lab_book_snapshot.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable/lab_book_snapshots/1
  # DELETE /Embeddable/lab_book_snapshots/1.xml
  def destroy
    @lab_book_snapshot = Embeddable::LabBookSnapshot.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(lab_book_snapshots_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @lab_book_snapshot.page_elements.each do |pe|
      pe.destroy
    end
    @lab_book_snapshot.destroy    
  end
end
