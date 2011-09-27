class RiGse::KnowledgeStatementsController < ApplicationController
  # GET /RiGse/knowledge_statements
  # GET /RiGse/knowledge_statements.xml
  def index
    @knowledge_statements = RiGse::KnowledgeStatement.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @knowledge_statements }
    end
  end

  # GET /RiGse/knowledge_statements/1
  # GET /RiGse/knowledge_statements/1.xml
  def show
    @knowledge_statement = RiGse::KnowledgeStatement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @knowledge_statement }
    end
  end

  # GET /RiGse/knowledge_statements/new
  # GET /RiGse/knowledge_statements/new.xml
  def new
    @knowledge_statement = RiGse::KnowledgeStatement.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @knowledge_statement }
    end
  end

  # GET /RiGse/knowledge_statements/1/edit
  def edit
    @knowledge_statement = RiGse::KnowledgeStatement.find(params[:id])
  end

  # POST /RiGse/knowledge_statements
  # POST /RiGse/knowledge_statements.xml
  def create
    @knowledge_statement = RiGse::KnowledgeStatement.new(params[:knowledge_statement])

    respond_to do |format|
      if @knowledge_statement.save
        flash[:notice] = 'RiGse::KnowledgeStatement.was successfully created.'
        format.html { redirect_to(@knowledge_statement) }
        format.xml  { render :xml => @knowledge_statement, :status => :created, :location => @knowledge_statement }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @knowledge_statement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /RiGse/knowledge_statements/1
  # PUT /RiGse/knowledge_statements/1.xml
  def update
    @knowledge_statement = RiGse::KnowledgeStatement.find(params[:id])

    respond_to do |format|
      if @knowledge_statement.update_attributes(params[:knowledge_statement])
        flash[:notice] = 'RiGse::KnowledgeStatement.was successfully updated.'
        format.html { redirect_to(@knowledge_statement) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @knowledge_statement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /RiGse/knowledge_statements/1
  # DELETE /RiGse/knowledge_statements/1.xml
  def destroy
    @knowledge_statement = RiGse::KnowledgeStatement.find(params[:id])
    @knowledge_statement.destroy

    respond_to do |format|
      format.html { redirect_to(knowledge_statements_url) }
      format.xml  { head :ok }
    end
  end
end
