# frozen_string_literal: true

module Pundit
  module ExpectedAttributeValues
    module ValueResolver
      module_function

      def resolve(source, policy)
        case source
        when Proc
          policy.instance_exec(&source)
        when Symbol
          policy.public_send(source)
        else
          source
        end
      end

      def resolve_hash_for_action(policy, action)
        action_method = "expected_attribute_values_for_#{action}"
        if policy.respond_to?(action_method, true)
          policy.public_send(action_method) || {}
        elsif policy.respond_to?(:expected_attribute_values_for_action, true)
          policy.expected_attribute_values_for_action(action) || {}
        elsif policy.respond_to?(:expected_attribute_values, true)
          policy.expected_attribute_values || {}
        else
          {}
        end
      end

      def normalize_list(values)
        Array(values).map { |v| normalize_value(v) }
      end

      def normalize_value(value)
        return value.to_sym if ExpectedAttributeValues.symbolize_values && value.respond_to?(:to_sym)

        value.is_a?(Symbol) ? value.to_s : value
      end
    end
  end
end
