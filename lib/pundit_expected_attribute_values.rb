# frozen_string_literal: true

require "pundit"
require "active_support/concern"

require_relative "pundit/expected_attribute_values/version"
require_relative "pundit/expected_attribute_values/configuration"
require_relative "pundit/expected_attribute_values/errors"
require_relative "pundit/expected_attribute_values/value_resolver"
require_relative "pundit/expected_attribute_values/filter"
require_relative "pundit/expected_attribute_values/policy"
require_relative "pundit/expected_attribute_values/expected_attributes_compat"
require_relative "pundit/expected_attribute_values/authorization"
require_relative "pundit/expected_attribute_values/test_helpers"

module Pundit
  module ExpectedAttributeValues
    class Error < StandardError; end

    def self.filter(params, policy, action:)
      Authorization.filter(params, policy, action: action)
    end
  end
end

require_relative "pundit/expected_attribute_values/railtie" if defined?(Rails::Railtie)
