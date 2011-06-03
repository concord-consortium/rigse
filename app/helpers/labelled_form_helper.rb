module LabelledFormHelper
  # this was taken from here: http://www.onrails.org/2008/06/13/advanced-rails-studio-custom-form-builder
  class LabellingFormBuilder < ActionView::Helpers::FormBuilder
    helpers = field_helpers +
              %w{date_select datetime_select time_select} +
              %w{collection_select select country_select time_zone_select} -
              %w{hidden_field label fields_for} # Don't decorate these

    helpers.each do |name|
      define_method(name) do |field, *args|
        options = args.extract_options!
        label = label(field, options[:label], :class => options[:label_class])
        @template.content_tag(:p, label +'<br/>' + super)  #wrap with a paragraph 
      end
    end
  end

  def labelled_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    form_for(record_or_name_or_array, *(args << options.merge(:builder => LabelledFormHelper::LabellingFormBuilder)), &proc)
  end
end