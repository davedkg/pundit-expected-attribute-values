ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# The gem's Minitest assertions: assert_permits_expected_value, assert_expected_values, ...
require "pundit/expected_attribute_values/minitest"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)
  end
end
