require 'benchmarks/benchmark_helper'

@owner = 'owner'
RedisSpecHelper.reset
DataBuilder.build(1000)

@results = {}

Benchmark.bm do |b|
  b.report('counting activities') do
    SirTracksAlot::Count.count({:owner => @owner}, {:limit => 999999}, :daily)
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

counts_count = SirTracksAlot::Count.all.size
summaries_count = SirTracksAlot::Summary.all.size
activities_count = SirTracksAlot::Activity.all.size

puts "*** Generated #{activities_count}, #{counts_count} counts (#{(counts_count+0.1)/(activities_count+0.1)}), #{summaries_count} summaries"

RedisSpecHelper.reset