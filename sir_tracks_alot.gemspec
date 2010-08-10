# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sir_tracks_alot}
  s.version = "0.4.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Peter T. Brown"]
  s.date = %q{2010-08-09}
  s.description = %q{A high speed general purpose tracking and reporting tool which uses Redis.}
  s.email = %q{peter@flippyhead.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "Gemfile",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "benchmarks/activity_benchmark.rb",
     "benchmarks/benchmark_helper.rb",
     "benchmarks/count_benchmark.rb",
     "benchmarks/report_benchmark.rb",
     "lib/sir_tracks_alot.rb",
     "lib/sir_tracks_alot/activity.rb",
     "lib/sir_tracks_alot/clock.rb",
     "lib/sir_tracks_alot/count.rb",
     "lib/sir_tracks_alot/event_helper.rb",
     "lib/sir_tracks_alot/filter_helper.rb",
     "lib/sir_tracks_alot/persistable.rb",
     "lib/sir_tracks_alot/queue/queue_helper.rb",
     "lib/sir_tracks_alot/queue/report_cache.rb",
     "lib/sir_tracks_alot/queue/report_config.rb",
     "lib/sir_tracks_alot/queue/report_queue.rb",
     "lib/sir_tracks_alot/reports/activity_report.rb",
     "lib/sir_tracks_alot/reports/actor_activity_report.rb",
     "lib/sir_tracks_alot/reports/actor_report.rb",
     "lib/sir_tracks_alot/reports/basic_report.rb",
     "lib/sir_tracks_alot/reports/filter_report.rb",
     "lib/sir_tracks_alot/reports/report.rb",
     "lib/sir_tracks_alot/reports/root_stem_report.rb",
     "lib/sir_tracks_alot/reports/simple_report.rb",
     "lib/sir_tracks_alot/reports/target_report.rb",
     "lib/sir_tracks_alot/reports/trackable_report.rb",
     "spec/activity_spec.rb",
     "spec/count_spec.rb",
     "spec/queue/report_config_spec.rb",
     "spec/queue/report_queue_spec.rb",
     "spec/redis_spec_helper.rb",
     "spec/reports/activity_report_spec.rb",
     "spec/reports/actor_activity_report_spec.rb",
     "spec/reports/actor_report_spec.rb",
     "spec/reports/basic_report_spec.rb",
     "spec/reports/filter_report_spec.rb",
     "spec/reports/report_spec.rb",
     "spec/reports/root_stem_report_spec.rb",
     "spec/reports/shared_report_specs.rb",
     "spec/reports/simple_report_spec.rb",
     "spec/reports/target_report_spec.rb",
     "spec/sir_tracks_alot_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "test/helper.rb",
     "test/test_sir_tracks_alot.rb",
     "views/reports/group.html.erb",
     "views/reports/table.html.erb"
  ]
  s.homepage = %q{http://github.com/flippyhead/sir_tracks_alot}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A high speed general purpose tracking and reporting tool which uses Redis.}
  s.test_files = [
    "spec/activity_spec.rb",
     "spec/count_spec.rb",
     "spec/queue/report_config_spec.rb",
     "spec/queue/report_queue_spec.rb",
     "spec/redis_spec_helper.rb",
     "spec/reports/activity_report_spec.rb",
     "spec/reports/actor_activity_report_spec.rb",
     "spec/reports/actor_report_spec.rb",
     "spec/reports/basic_report_spec.rb",
     "spec/reports/filter_report_spec.rb",
     "spec/reports/report_spec.rb",
     "spec/reports/root_stem_report_spec.rb",
     "spec/reports/shared_report_specs.rb",
     "spec/reports/simple_report_spec.rb",
     "spec/reports/target_report_spec.rb",
     "spec/sir_tracks_alot_spec.rb",
     "spec/spec_helper.rb",
     "test/helper.rb",
     "test/test_sir_tracks_alot.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<logging>, [">= 0"])
      s.add_runtime_dependency(%q<twitter>, [">= 0"])
      s.add_runtime_dependency(%q<ruport>, [">= 0"])
      s.add_runtime_dependency(%q<ohm>, [">= 0"])
      s.add_runtime_dependency(%q<redis>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rspec_hpricot_matchers>, [">= 0"])
      s.add_development_dependency(%q<hpricot>, [">= 0"])
    else
      s.add_dependency(%q<logging>, [">= 0"])
      s.add_dependency(%q<twitter>, [">= 0"])
      s.add_dependency(%q<ruport>, [">= 0"])
      s.add_dependency(%q<ohm>, [">= 0"])
      s.add_dependency(%q<redis>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rspec_hpricot_matchers>, [">= 0"])
      s.add_dependency(%q<hpricot>, [">= 0"])
    end
  else
    s.add_dependency(%q<logging>, [">= 0"])
    s.add_dependency(%q<twitter>, [">= 0"])
    s.add_dependency(%q<ruport>, [">= 0"])
    s.add_dependency(%q<ohm>, [">= 0"])
    s.add_dependency(%q<redis>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rspec_hpricot_matchers>, [">= 0"])
    s.add_dependency(%q<hpricot>, [">= 0"])
  end
end

