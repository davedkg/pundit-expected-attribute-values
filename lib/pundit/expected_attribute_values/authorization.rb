# frozen_string_literal: true

module Pundit
  module ExpectedAttributeValues
    module Authorization
      extend ActiveSupport::Concern

      included do
        prepend ExpectedAttributesCompat unless Pundit::Authorization.method_defined?(:expected_attributes)
        prepend ControllerMethods
      end

      module ControllerMethods
        def pundit_expected_attribute_values_for(record, attribute, action: action_name)
          policy(record).pundit_expected_attribute_values_for_attribute(attribute, action: action)
        end

        def expected_attributes(record, action: action_name, **options)
          raw = super
          apply_expected_values_filter(record, raw, action)
        end

        private

        def apply_expected_values_filter(record, params, action)
          policy_instance = policy(record)
          constraints = ValueResolver.resolve_hash_for_action(policy_instance, action)
          return params if constraints.empty?

          Filter.call(
            params,
            constraints,
            invalid: ExpectedAttributeValues.invalid_behavior,
            policy: policy_instance
          )
        end
      end

      class << self
        def filter(params, policy, action:)
          raise ArgumentError, "action is required" if action.nil?

          constraints = ValueResolver.resolve_hash_for_action(policy, action)
          Filter.call(
            params,
            constraints,
            invalid: ExpectedAttributeValues.invalid_behavior,
            policy: policy
          )
        end
      end
    end
  end
end
