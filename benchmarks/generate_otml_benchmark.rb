require 'rubygems'
require 'benchmark'
require 'open-uri'

host = 'http://localhost:3000'
path = '/investigations'

otml_doc_ids = %w{107 409 411 412 415 416 510 524 527 534 538}
@commands = otml_doc_ids.collect { |id| "curl -s #{host}#{path}/#{id}.otml" }

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

run_test
run_test
puts

# Benchmark.bmbm do |x|
#   otml_doc_urls.each do |url|
#     x.report(url) { `curl -s #{url}` }
#   end
# end
