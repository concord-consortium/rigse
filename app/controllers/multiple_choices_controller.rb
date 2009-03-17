class MultipleChoicesController < ApplicationController
  # GET /multiple_choices
  # GET /multiple_choices.xml
  def index
    @multiple_choices = MultipleChoice.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @multiple_choices }
    end
  end

  # GET /multiple_choices/1
  # GET /multiple_choices/1.xml
  def show
    @multiple_choice = MultipleChoice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @multiple_choice }
    end
  end

  # GET /multiple_choices/new
  # GET /multiple_choices/new.xml
  def new
    @multiple_choice = MultipleChoice.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @multiple_choice }
    end
  end

  # GET /multiple_choices/1/edit
  def edit
    @multiple_choice = MultipleChoice.find(params[:id])
  end

  # POST /multiple_choices
  # POST /multiple_choices.xml
  def create
    @multiple_choice = MultipleChoice.new(params[:multiple_choice])

    respond_to do |format|
      if @multiple_choice.save
        flash[:notice] = 'MultipleChoice was successfully created.'
        format.html { redirect_to(@multiple_choice) }
        format.xml  { render :xml => @multiple_choice, :status => :created, :location => @multiple_choice }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @multiple_choice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /multiple_choices/1
  # PUT /multiple_choices/1.xml
  def update
    @multiple_choice = MultipleChoice.find(params[:id])

    respond_to do |format|
      if @multiple_choice.update_attributes(params[:multiple_choice])
        flash[:notice] = 'MultipleChoice was successfully updated.'
        format.html { redirect_to(@multiple_choice) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @multiple_choice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /multiple_choices/1
  # DELETE /multiple_choices/1.xml
  def destroy
    @multiple_choice = MultipleChoice.find(params[:id])
    @multiple_choice.destroy

    respond_to do |format|
      format.html { redirect_to(multiple_choices_url) }
      format.xml  { head :ok }
    end
  end
end
