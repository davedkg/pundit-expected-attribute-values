# frozen_string_literal: true

module Pundit
  module ExpectedAttributeValues
    module TestHelpers
      module_function

      def expected_values_for(policy, attribute, action:)
        raise ArgumentError, "action is required" if action.nil?

        policy.pundit_expected_attribute_values_for_attribute(attribute, action: action)
      end

      def expects_value?(policy, attribute, value, action:)
        expected_values_for(policy, attribute, action: action).include?(
          ValueResolver.normalize_value(value)
        )
      end

      def refutes_expected_value?(policy, attribute, value, action:)
        !expects_value?(policy, attribute, value, action: action)
      end

      def matches_expected_values?(policy, attribute, expected, action:)
        actual = expected_values_for(policy, attribute, action: action)
        expected_list = ValueResolver.normalize_list(expected)
        actual.sort == expected_list.sort
      end
    end
  end
end
