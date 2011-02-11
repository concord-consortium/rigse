# Settings specified here will take precedence over those in config/environment.rb

# config.threadsafe!

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# FIXME: this should work:
#
#   config.gem "ffi-ncurses ", :version => "= 0.3.2.1"
#
# but the gem is not found in jruby for some reason ???
#
# Adding this to environment.rb is a hack that works for now:
#
#   $: << 'vendor/gems/ffi-ncurses-0.3.2.1/lib/'
#


# see http://nhw.pl/wp/2009/01/07/reloading-your-plugin-in-development-mode
# ActiveSupport::Dependencies.explicitly_unloadable_constants << 'Portal'
# ActiveSupport::Dependencies.explicitly_unloadable_constants << 'User'
# ActiveSupport::Dependencies.load_once_paths.delete_if {|p| p =~ /vendor\/plugins\/portal/ }
  
# textmate-footnotes
# Rails errors displayed in browser are generated with links to textmate
# see: http://wiki.github.com/josevalim/rails-footnotes
# config.gem "josevalim-rails-footnotes",  :lib => "rails-footnotes", :source => "http://gems.github.com"

unless RUBY_PLATFORM =~ /java/
  # See: http://www.datanoise.com/ruby-debug/
  require 'ruby-debug'
  # Debugger.wait_connection = true
  # Debugger.stop_on_connect = true
  # Debugger.start_remote
  Debugger.start
  Debugger.settings[:autolist] = 1
  Debugger.settings[:autoeval] = 1
  Debugger.settings[:reload_source_on_change] = 1
end

# to help with development with engines (which are plugins)
# config.reload_plugins = true
