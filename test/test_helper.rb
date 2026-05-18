# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "action_controller"
require "pundit"
require "pundit_expected_attribute_values"
require "minitest/autorun"

require_relative "support/policy_fixtures"
