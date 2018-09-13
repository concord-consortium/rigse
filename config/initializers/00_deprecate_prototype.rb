# Mostly copied from:
# https://github.com/rails/rails/blob/3-2-stable/activesupport/lib/active_support/deprecation/method_wrappers.rb
def deprecate_methods(target_module, *method_names)
  options = method_names.extract_options!
  method_names += options.keys

  method_names.each do |method_name|
    next if %i[[] << javascript_tag j escape_javascript javascript_cdata_section to_s call].include? method_name
    target_module.alias_method_chain(method_name, :deprecation) do |target, punctuation|
      target_module.module_eval(<<-end_eval, __FILE__, __LINE__ + 1)
        def #{target}_with_deprecation#{punctuation}(*args, &block)
          ::ActiveSupport::Deprecation.warn("Prototype Usage: #{method_name}", caller)
          send(:#{target}_without_deprecation#{punctuation}, *args, &block)
        end
      end_eval
    end
  end
end

# This must be done after_initialize because
# prototype_rails has its own engine initializer
# that runs after local/app initializers.
Rails.application.config.after_initialize do
  if ENV.fetch('DEPRECATE_PROTOTYPE', true) != 'false'
    namespaces = [
      ActionView::Helpers::PrototypeHelper,
      ActionView::Helpers::ScriptaculousHelper,
      ActionView::Helpers::JavaScriptHelper,
      ActionView::Helpers::PrototypeHelper::JavaScriptGenerator::GeneratorMethods,
      PrototypeHelper
    ]
    namespaces.each do |namespace|
      methods = namespace.public_instance_methods
      deprecate_methods(namespace, *methods)
    end
  end
end
