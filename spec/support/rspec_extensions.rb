# module RSpec
#   module Core
#     module Example
module FailsInThemes
  # wrapping mocks only works with the rspec mock framework right now...
  private
  def fails_in_themes(themes = {})
    $previous_mockspace = RSpec::Mocks.space
    RSpec::Mocks.space = RSpec::Mocks::Space.new
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
        raise RSpec::Core::Pending::PendingExampleFixedError.new("Expected to fail. No Error was raised.") if error.nil?
        raise RSpec::Core::Pending::PendingDeclaredInExample.new("Need to determine if failure is expected under theme: #{ApplicationController.get_theme}") if style == :todo
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
    RSpec::Mocks.space = $previous_mockspace
  end
end

#       module ExampleMethods
#         private

#         include FailsInThemes
#       end
#     end
#   end
# end
