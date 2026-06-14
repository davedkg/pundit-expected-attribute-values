# frozen_string_literal: true

require "rspec/expectations"
require_relative "test_helpers"

RSpec::Matchers.define :permit_expected_value do |attribute, value|
  match do |policy|
    action = @action || "update"
    Pundit::ExpectedAttributeValues::TestHelpers.expects_value?(policy, attribute, value, action: action)
  end

  chain :for_action do |action|
    @action = action
  end

  failure_message do |policy|
    action = @action || "update"
    expected = Pundit::ExpectedAttributeValues::TestHelpers.expected_values_for(policy, attribute, action: action)
    "expected policy to allow value #{value.inspect} for :#{attribute} on #{action}, " \
      "but expected values are #{expected.inspect}"
  end

  failure_message_when_negated do |policy|
    action = @action || "update"
    expected = Pundit::ExpectedAttributeValues::TestHelpers.expected_values_for(policy, attribute, action: action)
    "expected policy not to allow value #{value.inspect} for :#{attribute} on #{action}, " \
      "but it is in #{expected.inspect}"
  end

  description do
    "permit expected value :#{attribute} => #{value.inspect}"
  end
end

RSpec::Matchers.define :permit_expected_values do |attribute|
  chain :matching do |values|
    @expected = values
  end

  chain :for_action do |action|
    @action = action
  end

  match do |policy|
    raise ArgumentError, "Use .matching(%w[...]) to specify expected values" unless @expected

    action = @action || "update"
    Pundit::ExpectedAttributeValues::TestHelpers.matches_expected_values?(
      policy, attribute, @expected, action: action
    )
  end

  failure_message do |policy|
    action = @action || "update"
    actual = Pundit::ExpectedAttributeValues::TestHelpers.expected_values_for(policy, attribute, action: action)
    "expected policy to allow values #{@expected.inspect} for :#{attribute} on #{action}, " \
      "but expected values are #{actual.inspect}"
  end

  description do
    "permit expected values for :#{attribute}"
  end
end
