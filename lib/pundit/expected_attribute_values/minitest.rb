# frozen_string_literal: true

require_relative "test_helpers"

module Pundit
  module ExpectedAttributeValues
    module MinitestAssertions
      def assert_permits_expected_value(policy, attribute, value, action: "update")
        assert ExpectedAttributeValues::TestHelpers.expects_value?(policy, attribute, value, action: action),
               "Expected policy to allow value #{value.inspect} for :#{attribute} on #{action}"
      end

      def refute_permits_expected_value(policy, attribute, value, action: "update")
        refute ExpectedAttributeValues::TestHelpers.expects_value?(policy, attribute, value, action: action),
               "Expected policy not to allow value #{value.inspect} for :#{attribute} on #{action}"
      end

      def assert_expected_values(policy, attribute, expected, action: "update")
        assert ExpectedAttributeValues::TestHelpers.matches_expected_values?(
          policy, attribute, expected, action: action
        ),
               lambda {
                 actual = ExpectedAttributeValues::TestHelpers.expected_values_for(policy, attribute, action: action)
                 "Expected values #{expected.inspect} for :#{attribute} on #{action}, got #{actual.inspect}"
               }
      end
    end
  end
end

Minitest::Test.include Pundit::ExpectedAttributeValues::MinitestAssertions if defined?(Minitest::Test)
