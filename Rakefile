# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "minitest/test_task"

RSpec::Core::RakeTask.new(:spec)

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

desc "Run Minitest and RSpec"
task test_all: %i[test spec]

task default: :test_all
