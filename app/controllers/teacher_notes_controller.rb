class TeacherNotesController < ApplicationController
  
  # PUNDIT_CHECK_FILTERS
  before_filter :setup_object, :except => [:index]
    
  protected
  
  def set_owner(note)
    if (! note.authored_entity.nil?)
      note.user = note.authored_entity.user
    else
      note.user = current_visitor
    end
  end
  
  public
  def setup_object
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize TeacherNote
    # authorize @teacher_note
    # authorize TeacherNote, :new_or_create?
    # authorize @teacher_note, :update_edit_or_destroy?
    if params[:id]
      if valid_uuid(params[:id])
        @teacher_note = TeacherNote.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @teacher_note = TeacherNote.find(params[:id])
      end
    elsif params[:teacher_note]
      @teacher_note = TeacherNote.new(params[:activity])
      @teacher_note.authored_entity_type=params[:authored_entity_type]
      @teacher_note.authored_entity_id=params[:authored_entity_id]
      set_owner @teacher_note
    elsif params[:authored_entity_type] && params[:authored_entity_id]
      @teacher_note = TeacherNote.find_by_authored_entity_type_and_authored_entity_id(params[:authored_entity_type],params[:authored_entity_id])
      if (@teacher_note.nil?)
        @teacher_note = TeacherNote.new
        @teacher_note.authored_entity_type=params[:authored_entity_type]
        @teacher_note.authored_entity_id=params[:authored_entity_id]
        set_owner @teacher_note
      end
    else
      @teacher_note = TeacherNote.new
      set_owner @teacher_note
    end
  end
  
  def show_teacher_note
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize TeacherNote
    # authorize @teacher_note
    # authorize TeacherNote, :new_or_create?
    # authorize @teacher_note, :update_edit_or_destroy?
    if @teacher_note.changeable?(current_visitor)
      render :update do |page|
          page.replace_html  'note', :partial => 'teacher_notes/remote_form', :locals => { :teacher_note => @teacher_note}
          page.visual_effect :toggle_blind, 'note'
      end
    else
      render :update do |page|
        page.replace_html  'note', :partial => 'teacher_notes/show', :locals => { :teacher_note => @teacher_note  }
        page.visual_effect :toggle_blind, 'note'
      end
    end
  end
  
  
  # GET /teacher_notes
  # GET /teacher_notes.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize TeacherNote
    @teacher_notes = TeacherNote.all
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (found instance)
    @teacher_notes = policy_scope(TeacherNote)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teacher_notes }
    end
  end

  # GET /teacher_notes/1
  # GET /teacher_notes/1.xml
  def show
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    authorize @teacher_note
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @teacher_note }
    end
  end

  # GET /teacher_notes/new
  # GET /teacher_notes/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize TeacherNote
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @teacher_note }
    end
  end

  # GET /teacher_notes/1/edit
  def edit
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    authorize @teacher_note
  end

  # POST /teacher_notes
  # POST /teacher_notes.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize TeacherNote
    if (@teacher_note.changeable?(current_visitor) && @teacher_note.update_attributes(params[:teacher_note]))
      if (request.xhr?)
        render :text => "<div class='notice'>teacher note saved</div>"
      else
        respond_to do |format|
          flash[:notice] = 'TeacherNote was successfully updated.'
          format.html { redirect_to(@teacher_note) }
          format.xml  { head :ok }
        end
      end
    else
      if (request.xhr?)
         render :text => "<div class='notice'>Cant save note.</div>"
      else
        respond_to do |format|
          flash[:notice] = 'You can not modify this Teachernote.'
          format.html { redirect_to(@teacher_note) }
          format.xml  { head :ok }
        end
      end
    end
  end

  # PUT /teacher_notes/1
  # PUT /teacher_notes/1.xml
  def update
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    authorize @teacher_note
    if (@teacher_note.changeable?(current_visitor) && @teacher_note.update_attributes(params[:teacher_note]))
      if (request.xhr?)
        render :text => "<div class='notice'>teacher note saved</div>"
      else
        respond_to do |format|
          flash[:notice] = 'TeacherNote was successfully updated.'
          format.html { redirect_to(@teacher_note) }
          format.xml  { head :ok }
        end
      end
    else
      if (request.xhr?)
         render :text => "<div class='notice'>Cant save note.</div>"
      else
        respond_to do |format|
          flash[:notice] = 'You can not modify this Teachernote.'
          format.html { redirect_to(@teacher_note) }
          format.xml  { head :ok }
        end
      end
    end
  end

  # DELETE /teacher_notes/1
  # DELETE /teacher_notes/1.xml
  def destroy
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    authorize @teacher_note
    if(@teacher_note.changeable?(current_visitor))
      @teacher_note.destroy
      respond_to do |format|
        format.html { redirect_to(teacher_notes_url) }
        format.xml  { head :ok }
      end
    else 
      respond_to do |format|
        flash[:notice] = 'You can not modify this Teachernote.'
        format.html { redirect_to(@teacher_note) }
        format.xml  { head :ok }
      end
    end
  end
end
