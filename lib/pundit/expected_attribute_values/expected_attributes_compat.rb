# frozen_string_literal: true

module Pundit
  module ExpectedAttributeValues
    # Provides Pundit 2.6's +expected_attributes+ on controllers until a released
    # Pundit version includes it. Not used when +Pundit::Authorization+ already
    # defines the method.
    module ExpectedAttributesCompat
      def expected_attributes(record, action: action_name, param_key: pundit_param_key(record))
        policy_instance = policy(record)
        shape = policy_instance.expected_attributes_for_action(action)
        params.expect(param_key => shape)
      end

      def pundit_param_key(record)
        Pundit::PolicyFinder.new(record).param_key
      end
    end
  end
end
