class InvestigationSweeper < ActionController::Caching::Sweeper
  
  observe Investigation
   
  # If we create a new investigation, the public list of articles must be regenerated 
  # def after_create(investigation) 
  #   expire_public_page 
  # end 
  
  # If we update an existing investigation, the cached version of that investigation is stale 
  def after_update(investigation)
    path = "#{RAILS_ROOT}/public/investigations/#{investigation.id}.otml"
    File.delete(path) if File.exists?(path)
  end

  # Deleting an investigation means we update the public list and blow away the cached investigation 
  # def after_destroy(investigation) 
  #   # expire_public_page 
  #   expire_investigation_page(investigation.id) 
  # end

  # private 
  # 
  # def expire_public_page 
  #   expire_page(:controller => "investigation", :action => 'public_content') 
  # end
  #  
  # def expire_investigation_page(investigation_id) 
  #   debugger
  #   expire_action(:controller => "investigation", :action => "show", :id => investigation_id) 
  # end 
  # 
end