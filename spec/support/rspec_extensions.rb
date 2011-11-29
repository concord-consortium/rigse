module Spec
  module Example
    module FailsInThemes
      # wrapping mocks only works with the rspec mock framework right now...
      def fails_in_themes(themes = {})
        $previous_mockspace = $rspec_mocks
        $rspec_mocks = Spec::Mocks::Space.new
        if block_given?
          error = nil
          begin
            yield
            verify_mocks_for_rspec
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
      ensure
        teardown_mocks_for_rspec
        $rspec_mocks = $previous_mockspace
        $previous_mockspace = nil
      end
    end

    module ExampleMethods
      private

      include FailsInThemes
    end
  end
end
