# frozen_string_literal: true

module Pundit
  module ExpectedAttributeValues
    module Policy
      extend ActiveSupport::Concern

      def expected_attribute_values_for_action(action_name)
        action_method = "expected_attribute_values_for_#{action_name}"
        if respond_to?(action_method, true)
          public_send(action_method) || {}
        elsif respond_to?(:expected_attribute_values, true)
          expected_attribute_values || {}
        else
          {}
        end
      end

      def pundit_expected_attribute_values_for_attribute(attribute, action:)
        raise ArgumentError, "action is required" if action.nil?

        hash = expected_attribute_values_for_action(action.to_s)
        source = hash[attribute.to_sym] || hash[attribute.to_s]
        return [] unless source

        ValueResolver.normalize_list(ValueResolver.resolve(source, self))
      end
    end
  end
end
