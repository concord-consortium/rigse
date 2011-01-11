class PageElementsController < ApplicationController
  
  protected

  def toggle_enabled(isit)
    page_element = PageElement.find(params[:id])
    results = :bad_request
    if page_element.changeable?(current_user)
      page_element.is_enabled=isit
      if page_element.save
        results = :ok
      end
    end
    head results
  end

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
  
  def enable
    toggle_enabled(true)
  end

  def disable
    toggle_enabled(false)
  end

end
