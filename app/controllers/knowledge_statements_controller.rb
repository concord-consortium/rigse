class KnowledgeStatementsController < ApplicationController
  # GET /knowledge_statements
  # GET /knowledge_statements.xml
  def index
    @knowledge_statements = KnowledgeStatement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @knowledge_statements }
    end
  end

  # GET /knowledge_statements/1
  # GET /knowledge_statements/1.xml
  def show
    @knowledge_statement = KnowledgeStatement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @knowledge_statement }
    end
  end

  # GET /knowledge_statements/new
  # GET /knowledge_statements/new.xml
  def new
    @knowledge_statement = KnowledgeStatement.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @knowledge_statement }
    end
  end

  # GET /knowledge_statements/1/edit
  def edit
    @knowledge_statement = KnowledgeStatement.find(params[:id])
  end

  # POST /knowledge_statements
  # POST /knowledge_statements.xml
  def create
    @knowledge_statement = KnowledgeStatement.new(params[:knowledge_statement])

    respond_to do |format|
      if @knowledge_statement.save
        flash[:notice] = 'KnowledgeStatement was successfully created.'
        format.html { redirect_to(@knowledge_statement) }
        format.xml  { render :xml => @knowledge_statement, :status => :created, :location => @knowledge_statement }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @knowledge_statement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /knowledge_statements/1
  # PUT /knowledge_statements/1.xml
  def update
    @knowledge_statement = KnowledgeStatement.find(params[:id])

    respond_to do |format|
      if @knowledge_statement.update_attributes(params[:knowledge_statement])
        flash[:notice] = 'KnowledgeStatement was successfully updated.'
        format.html { redirect_to(@knowledge_statement) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @knowledge_statement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /knowledge_statements/1
  # DELETE /knowledge_statements/1.xml
  def destroy
    @knowledge_statement = KnowledgeStatement.find(params[:id])
    @knowledge_statement.destroy

    respond_to do |format|
      format.html { redirect_to(knowledge_statements_url) }
      format.xml  { head :ok }
    end
  end
end
