module CcAngularHelper

  def uiselect(opts = {})
    opts['theme']          ||= "select2"
    opts['search-enabled'] ||= opts[:search]
    if opts['ng-model']
      opts['name']         ||= opts['ng-model'].split(".")[-1]
    end
    match_opts            ||= {}
    if opts['palceholder']
      match_opts['placeholder'] = opts.delete('palceholder')
    end
    choice_opts           ||= {}
    if opts['collection']
      match_opts['repeat'] = "item in #{opts.delete('collection')}"
    end
    display_field = opts.delete('display_field')

    capture_haml do
      haml_tag 'ui-select', opts do
        haml_tag 'ui-select-match', match_opts do
          haml_concat "{{$select.selected}}"
        end
        haml_tag 'ui-select-choices', choice_opts do
          if display_field
            haml_concat "{{question.#{display_field}}}"
          else
            haml_concat "{{item}}"
          end
        end
      end
    end
  end
end