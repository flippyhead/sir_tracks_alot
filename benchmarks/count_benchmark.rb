require 'benchmarks/benchmark_helper'

@owner = 'owner'
RedisSpecHelper.reset
DataBuilder.build(10000)

Benchmark.bmbm do |b|
  b.report('counting activities') do
    SirTracksAlot::Count.count(:owner => @owner)
  end

  b.report('building rows for reports') do
    SirTracksAlot::Count.rows(:owner => @owner)
  end

  b.report('filtering counts by owner') do
    SirTracksAlot::Count.find(:owner => @owner)
  end

  b.report('filtering counts with regex') do
    SirTracksAlot::Count.rows(:owner => @owner, :target => /.+/)
  end
end

RedisSpecHelper.reset