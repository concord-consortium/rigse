require 'rubygems'
require 'benchmark'
require 'open-uri'
require 'fileutils'

# These benchmarks are currently designed to work with a copy of
# the current RITES production database.
#
# If you have ssh access to the RITES production server you can get
# this database as follows:
#
#   cap production db:fetch_remote_db
#   RAILS_ENV=production jruby -S rake db:load
#   RAILS_ENV=production jruby -S rake db:migrate
# 
# Then start the server with either:
#
#   jruby -J-server script/server -e production
#
# or using MRI:
#
#   script/server -e production
#
# and then run in another shell:
#
#   ruby benchmarks/generate_otml_benchmark.rb
#

host = 'http://localhost:3000'
path = '/investigations'

otml_doc_ids = %w{107 409 411 412 415 416 510 524 527 534 538}
@commands = otml_doc_ids.collect { |id| "curl -s #{host}#{path}/#{id}.otml" }

RAILS_ROOT = Dir.getwd 

def clear_otml_page_cache
  Dir["#{RAILS_ROOT}/public/investigations/**/*.otml"].each {|f| FileUtils.rm(f) }
end

def run_test
  puts
  elapsed_time = 0
  @commands.each do |command|
    print command + '    '
    time = Benchmark.realtime { `#{command}` }
    puts sprintf('%5.3f', time)
    elapsed_time += time
  end
  puts "\n total elapsed time: #{sprintf('%5.3f', elapsed_time)}\n"
end

2.times {
  clear_otml_page_cache
  run_test
}
