
require 'benchmark'

def task
  tmp_array = []
  10_000_000.times { |n| tmp_array << n }
end

task_method = method(:task)

@threads = []
Benchmark.bm(14) do |x| 

  x.report('no-threads') do
    2.times do
      task
    end
  end

  x.report('with-threads') do
    2.times do
      @threads << Thread.new(&task_method)
    end
    @threads.each(&:join)
  end
end