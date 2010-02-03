# http://ethilien.net/archives/fixing-divfieldwitherrors-in-ruby-on-rails/
# https://rails.lighthouseapp.com/projects/8994/tickets/1626-fieldwitherrors-shouldnt-use-a-div
ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| "<span class=\"fieldWithErrors\">#{html_tag}</span>" }
