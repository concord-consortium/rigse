if teacher_mode && runnable.class == Investigation 
  otml_url = investigation_teacher_dynamic_otml_url(runnable)
else
  otml_url = polymorphic_url(runnable, :format => :dynamic_otml, :teacher_mode => teacher_mode)
end

xml << render( :partial => 'shared/sail', :locals => {
  :otml_url => otml_url, 
  :properties => { 'sailotrunk.hidetree' => 'false' },
  :session_id => session_id,
})
