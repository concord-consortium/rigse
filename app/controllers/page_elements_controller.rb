class PageElementsController < ApplicationController
  toggle_controller_for :page_elements

  public
  # DELETE /page_elements/1
  # DELETE /page_elements/1.xml
  def destroy
    @page_element = PageElement.find(params[:id])
    @page_element.destroy
    respond_to do |format|
      format.html { redirect_to(page_elements_url) }
      format.xml  { head :ok }
      format.js
    end
  end


end
