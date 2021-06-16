module ErrorHelper

  # @template.content_tag(:p, label + "<br/>".html_safe + super(field, *args))  #wrap with a paragraph
  # tag.div tag.p('Hello world!')
  # '2 errors prevented saving name
  def error_messages_for(active_record_object, opts=nil)

    if !active_record_object.valid?
      name = (opts && opts[:object_name]) || active_record_object && active_record_object.model_name.human
      errors = active_record_object.errors
      summary_string = "#{errors.attribute_names.length} errors found for #{name}"
      tag.div class: 'error' do
        concat(summary_string)
        concat(
          tag.ul do
            errors.map { |e| concat(tag.li e.full_message) }
          end
        )
      end
    end
  end
end

