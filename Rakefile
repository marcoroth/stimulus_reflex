# frozen_string_literal: true

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)

require "bundler/setup"
require "bundler/gem_tasks"
require "rails/test_unit/runner"
require "rake/testtask"

load "rails/tasks/engine.rake"
load "rails/tasks/statistics.rake"

task :test_javascript do |task|
  system "yarn run test"
end

task :test_ruby do |task|
  Rails::TestUnit::Runner.run
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = false
end

task default: :test
