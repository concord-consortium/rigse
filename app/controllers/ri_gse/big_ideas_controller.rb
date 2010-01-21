class RiGse::BigIdeasController < ApplicationController
  # GET /RiGse/big_ideas
  # GET /RiGse/big_ideas.xml
  def index
    @big_ideas = RiGse::BigIdea.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @big_ideas }
    end
  end

  # GET /RiGse/big_ideas/1
  # GET /RiGse/big_ideas/1.xml
  def show
    @big_idea = RiGse::BigIdea.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @big_idea }
    end
  end

  # GET /RiGse/big_ideas/new
  # GET /RiGse/big_ideas/new.xml
  def new
    @big_idea = RiGse::BigIdea.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @big_idea }
    end
  end

  # GET /RiGse/big_ideas/1/edit
  def edit
    @big_idea = RiGse::BigIdea.find(params[:id])
  end

  # POST /RiGse/big_ideas
  # POST /RiGse/big_ideas.xml
  def create
    @big_idea = RiGse::BigIdea.new(params[:big_idea])

    respond_to do |format|
      if @big_idea.save
        flash[:notice] = 'RiGse::BigIdea.was successfully created.'
        format.html { redirect_to(@big_idea) }
        format.xml  { render :xml => @big_idea, :status => :created, :location => @big_idea }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @big_idea.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /RiGse/big_ideas/1
  # PUT /RiGse/big_ideas/1.xml
  def update
    @big_idea = RiGse::BigIdea.find(params[:id])

    respond_to do |format|
      if @big_idea.update_attributes(params[:big_idea])
        flash[:notice] = 'RiGse::BigIdea.was successfully updated.'
        format.html { redirect_to(@big_idea) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @big_idea.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /RiGse/big_ideas/1
  # DELETE /RiGse/big_ideas/1.xml
  def destroy
    @big_idea = RiGse::BigIdea.find(params[:id])
    @big_idea.destroy

    respond_to do |format|
      format.html { redirect_to(big_ideas_url) }
      format.xml  { head :ok }
    end
  end
end
