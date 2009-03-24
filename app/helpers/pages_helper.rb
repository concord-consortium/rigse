module PagesHelper
  
  def link_to_ajax_delete(page,component)
    link_to_remote 'delete',  
      :confirm => "Delete this item?", 
      :html => {:class => 'delete'}, 
      :url => { 
        :action => 'delete_element', 
        :dom_id =>page.element_for(component).dom_id, 
        :element_id => page.element_for(component).id
      }
  end
  
end
