xml << render( :partial => 'shared/sail', :locals => {
  :otml_url => polymorphic_url(runnable, :format => :dynamic_otml), 
  :session_id => session_id,
  :console_post_url => dataservice_console_logger_console_contents_url(console_logger, :format => :bundle),
  :bundle_url => dataservice_bundle_logger_url(bundle_logger, :format => :bundle),
  :bundle_post_url => dataservice_bundle_logger_bundle_contents_url(bundle_logger, :format => :bundle)
})
