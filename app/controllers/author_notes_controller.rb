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
    respond_to do |format|
      format.js   { render :update do |page| 
        page.visual_effect :highlite, 'note' 
        end 
      }
    end
  end

  # POST /author_notes
  # POST /author_notes.xml
  def create
    @author_note = AuthorNote.new(params[:author_note])    
    if @author_note.save
      flash[:notice] = 'AuthorNote was successfully created.'
      if (request.xhr?)
         render :text => "<div class='notice'>Author note saved</div>"
      else
        respond_to do |format|
          format.html { redirect_to(@author_note) }
          format.xml  { render :xml => @author_note, :status => :created, :location => @author_note }
        end
      end
    end
  end

  # PUT /author_notes/1
  # PUT /author_notes/1.xml
  def update
    @author_note = AuthorNote.find(params[:id])
    if @author_note.update_attributes(params[:author_note])
      if (request.xhr?)
         render :text => "<div class='notice'>Author note saved</div>"
      else
        respond_to do |format|
          flash[:notice] = 'AuthorNote was successfully created.'
          format.html { redirect_to(@author_note) }
          format.xml  { render :xml => @author_note, :status => :created, :location => @author_note }
        end
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
