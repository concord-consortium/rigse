module Spec
  module Example
    module FailsInThemes
      def fails_in_themes(themes = {})
        if block_given?
          error = nil
          begin
            yield
            error = nil
          rescue Exception => e
            error = e
          end

          if style = themes[ApplicationController.get_theme]
            # expect this to fail
            raise Spec::Example::PendingExampleFixedError.new("Expected to fail. No Error was raised.") if error.nil?
            raise Spec::Example::ExamplePendingError.new("Need to determine if failure is expected under theme: #{ApplicationController.get_theme}") if style == :todo
          else
            # otherwise pass any exceptions upstream
            raise error unless error.nil?
          end
        else
          # require a block to be passed in
          raise "No block passed for fails_in_themes"
        end
      end
    end

    module ExampleMethods
      private

      include FailsInThemes
    end
  end
end
