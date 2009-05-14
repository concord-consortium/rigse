class AuthorNotesController < ApplicationController
  # GET /author_notes
  # GET /author_notes.xml
  def index
    @author_notes = AuthorNote.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @author_notes }
    end
  end

  # GET /author_notes/1
  # GET /author_notes/1.xml
  def show
    @author_note = AuthorNote.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @author_note }
    end
  end

  # GET /author_notes/new
  # GET /author_notes/new.xml
  def new
    @author_note = AuthorNote.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @author_note }
    end
  end

  # GET /author_notes/1/edit
  def edit
    @author_note = AuthorNote.find(params[:id])
  end

  # POST /author_notes
  # POST /author_notes.xml
  def create
    @author_note = AuthorNote.new(params[:author_note])
    respond_to do |format|
      if @author_note.save
        flash[:notice] = 'AuthorNote was successfully created.'
        format.html { redirect_to(@author_note) }
        format.xml  { render :xml => @author_note, :status => :created, :location => @author_note }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @author_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /author_notes/1
  # PUT /author_notes/1.xml
  def update
    @author_note = AuthorNote.find(params[:id])
    respond_to do |format|
      if @author_note.update_attributes(params[:author_note])
        flash[:notice] = 'AuthorNote was successfully updated.'
        format.html { redirect_to(@author_note) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @author_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /author_notes/1
  # DELETE /author_notes/1.xml
  def destroy
    @author_note = AuthorNote.find(params[:id])
    @author_note.destroy

    respond_to do |format|
      format.html { redirect_to(author_notes_url) }
      format.xml  { head :ok }
    end
  end
end
