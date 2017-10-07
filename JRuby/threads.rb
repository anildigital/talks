require 'benchmark'

ary = (1..1000000).to_a

loop {
  puts Benchmark.measure {
    10.times {
      Thread.new {
        ary.each { |i| }
      } 
    }
  }
}