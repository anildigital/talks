require 'open-uri'
require 'benchmark'

URL = 'http://google.com'
TIMES = 15.times

puts "RUBY_PLATFORM #{RUBY_PLATFORM}"
puts "RUBY_VERSION #{RUBY_VERSION}\n\n"

def without_threads
  TIMES.map { open(URL) }
end

def with_threads
  TIMES.map do
    Thread.new { open(URL) }
  end.each(&:join)
end

Benchmark.bm do |x|
  x.report("Without threads\n") { 
     without_threads 
  }
  x.report("With threads\n") { 
     with_threads 
  }
end
