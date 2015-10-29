class AttachedFilesController < ApplicationController
  # PUNDIT_CHECK_FILTERS
  before_filter :authenticate_user!

  def destroy
    @attached_file = AttachedFile.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # authorize @attached_file
    @attached_file.destroy if @attached_file.changeable?(current_visitor)
    redirect_back_or @attached_file.attachable
  end
end
