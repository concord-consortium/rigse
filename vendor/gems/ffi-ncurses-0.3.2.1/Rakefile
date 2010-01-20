# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

if File.exist?('local/config.rb')
  load 'local/config.rb'
end

ensure_in_path 'lib'
require 'ffi-ncurses'

task :default => 'spec:run'

Bones {
  name              'ffi-ncurses'
  authors           "Sean O'Halpin"
  email             'sean.ohalpin@gmail.com'
  url               'http://github.com/seanohalpin/ffi-ncurses'
  summary           'FFI wrapper for ncurses'
  version           FFI::NCurses::VERSION
  # rubyforge.name    'ffi-ncurses'
  readme_file       'README.rdoc'
  description  <<-EOT
A wrapper for ncurses 5.x. Tested on Mac OS X 10.4 (Tiger) and Ubuntu
8.04 with ruby 1.8.6 using ruby-ffi (>= 0.2.0) and JRuby 1.1.6.

The API is very much a transliteration of the C API rather than an
attempt to provide an idiomatic Ruby object-oriented API. The intent
is to provide a 'close to the metal' wrapper around the ncurses
library upon which you can build your own abstractions.

See the examples directory for real working examples.
  EOT

  rdoc.exclude ['^notes']
  readme_file  'README.rdoc'

  # spec
  spec.opts '--color'

  # files
  exclude  %w(tmp$ bak$ ~$ CVS \.svn ^pkg ^doc \.git local notes \.DS_Store)
  exclude << '^tags$' << "^bug" << "^tools"
  exclude << File.read('.gitignore').split(/\n/)
  exclude << 'README.txt'

  colorize false
}
