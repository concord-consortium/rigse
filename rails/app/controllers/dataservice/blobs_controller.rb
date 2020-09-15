class Dataservice::BlobsController < ApplicationController

  protected

  def is_admin?
    return (current_visitor != nil && current_visitor.has_role?('admin'))
  end

  public

  # 2020-09-15 NP: The index route is needed, because `blobs_url` is used
  # to do path construction in reports, eg `/services/reports/detail.rb` line ~170
  def index
    authorize Dataservice::Blob
    @dataservice_blobs = policy_scope(Dataservice::Blob).search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html { head :ok }
      format.xml  { render :xml => @dataservice_blobs }
    end
  end

  # 2020-09-15 NP: We need this to render images in the reports.
  def show
    @dataservice_blob = Dataservice::Blob.find(params[:id])
    # leaving manual authorization in place because of the params check and the formatting error options
    is_authorized = is_admin? || (@dataservice_blob && @dataservice_blob.token == params[:token]) || current_visitor.has_role?('researcher')

    respond_to do |format|
      format.html {
        raise Pundit::NotAuthorizedError unless is_authorized
        head :ok
      }
      format.xml  {
        raise Pundit::NotAuthorizedError unless is_authorized
        render :xml => @dataservice_blob
      }
      format.png  {
        _handle_rendering_blob(is_authorized)
      }
      format.blob  {
        _handle_rendering_blob(is_authorized)
      }
    end
  end

# TODO: NP 2020-09-15 — See if we can remove this action
  def create
    @dataservice_blob = Dataservice::Blob.new(params[:blob])
    authorize @dataservice_blob

    respond_to do |format|
      if @dataservice_blob.save
        flash[:notice] = 'Dataservice::Blob was successfully created.'
        format.html { head :ok }
        format.xml  { render :xml => @dataservice_blob, :status => :created, :location => @dataservice_blob }
      else
        format.html { head :unprocessable_entity }
        format.xml  { render :xml => @dataservice_blob.errors, :status => :unprocessable_entity }
      end
    end
  end

  # TODO: NP 2020-09-15 — See if we can remove this action
  def update
    @dataservice_blob = Dataservice::Blob.find(params[:id])
    authorize @dataservice_blob

    respond_to do |format|
      if @dataservice_blob.update_attributes(params[:blob])
        flash[:notice] = 'Dataservice::Blob was successfully updated.'
        format.html { head :ok }
        format.xml  { head :ok }
      else
        format.html { head :unprocessable_entity }
        format.xml  { render :xml => @dataservice_blob.errors, :status => :unprocessable_entity }
      end
    end
  end


  private

  def _handle_rendering_blob(is_authorized)
    if is_authorized
      type = params[:mimetype] ? params[:mimetype] : @dataservice_blob.mimetype
      send_data(@dataservice_blob.content, :type => type, :filename => "file", :disposition => 'inline' )
    else
      render :text => "<error>Forbidden</error>", :status => :forbidden  # Forbidden
    end
  end
end
