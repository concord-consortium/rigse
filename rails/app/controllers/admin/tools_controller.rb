class Admin::ToolsController < ApplicationController

  public

  def index
    authorize Tool
    @tools = Tool.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /tools/1
  def show
    @tool = Tool.find(params[:id])
    authorize @tool

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /tools/new
  def new
    authorize Tool
    @tool = Tool.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /tools/1/edit
  def edit
    @tool = Tool.find(params[:id])
    authorize @tool
  end

  # POST /tools
  def create
    authorize Tool
    @tool = Tool.new(tool_strong_params(params[:tool]))

    respond_to do |format|
      if @tool.save
        format.html { redirect_to admin_tools_path, notice: 'Tool was successfully created.' }
        format.json { render json: @tool, status: :created, location: @tool }
      else
        format.html { render action: "new" }
        format.json { render json: @tool.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tools/1
  def update
    @tool = Tool.find(params[:id])
    authorize @tool

    respond_to do |format|
      if @tool.update(tool_strong_params(params[:tool]))
        format.html { redirect_to admin_tools_path, notice: 'Tool was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tool.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tools/1
  def destroy
    @tool = Tool.find(params[:id])
    authorize @tool
    @tool.destroy

    respond_to do |format|
      format.html { redirect_to(admin_tools_url) }
    end
  end

  def tool_strong_params(params)
    params && params.permit(:name, :source_type, :tool_id)
  end
end
