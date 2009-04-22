class TeacherNotesController < ApplicationController
  # GET /teacher_notes
  # GET /teacher_notes.xml
  def index
    @teacher_notes = TeacherNote.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teacher_notes }
    end
  end

  # GET /teacher_notes/1
  # GET /teacher_notes/1.xml
  def show
    @teacher_note = TeacherNote.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @teacher_note }
    end
  end

  # GET /teacher_notes/new
  # GET /teacher_notes/new.xml
  def new
    @teacher_note = TeacherNote.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @teacher_note }
    end
  end

  # GET /teacher_notes/1/edit
  def edit
    @teacher_note = TeacherNote.find(params[:id])
  end

  # POST /teacher_notes
  # POST /teacher_notes.xml
  def create
    @teacher_note = TeacherNote.new(params[:teacher_note])

    respond_to do |format|
      if @teacher_note.save
        flash[:notice] = 'TeacherNote was successfully created.'
        format.html { redirect_to(@teacher_note) }
        format.xml  { render :xml => @teacher_note, :status => :created, :location => @teacher_note }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @teacher_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /teacher_notes/1
  # PUT /teacher_notes/1.xml
  def update
    @teacher_note = TeacherNote.find(params[:id])

    respond_to do |format|
      if @teacher_note.update_attributes(params[:teacher_note])
        flash[:notice] = 'TeacherNote was successfully updated.'
        format.html { redirect_to(@teacher_note) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @teacher_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /teacher_notes/1
  # DELETE /teacher_notes/1.xml
  def destroy
    @teacher_note = TeacherNote.find(params[:id])
    @teacher_note.destroy

    respond_to do |format|
      format.html { redirect_to(teacher_notes_url) }
      format.xml  { head :ok }
    end
  end
end
