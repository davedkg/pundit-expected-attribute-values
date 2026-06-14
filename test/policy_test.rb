# frozen_string_literal: true

require "test_helper"

class PolicyTest < Minitest::Test
  def test_admin_expected_roles
    policy = TestUserPolicy.new(TestUser.new(admin: true), TestRecord.new)
    assert_equal %w[user manager admin],
                 policy.pundit_expected_attribute_values_for_attribute(:role, action: "update")
  end

  def test_manager_expected_roles
    policy = TestUserPolicy.new(TestUser.new(manager: true), TestRecord.new)
    assert_equal %w[user], policy.pundit_expected_attribute_values_for_attribute(:role, action: "update")
  end

  def test_action_specific_values
    policy = TestUserUpdatePolicy.new(TestUser.new(admin: true), TestRecord.new)
    assert_equal %w[user], policy.pundit_expected_attribute_values_for_attribute(:role, action: "update")
  end

  def test_collection_attribute_from_static_array_source
    policy = TestUserPolicy.new(TestUser.new(admin: true), TestRecord.new)
    assert_equal %w[ruby rails pundit],
                 policy.pundit_expected_attribute_values_for_attribute(:tags, action: "update")
  end

  def test_collection_attribute_from_method_reference_source
    policy = TestUserPolicy.new(TestUser.new(admin: true), TestRecord.new)
    assert_equal %w[bug feature chore],
                 policy.pundit_expected_attribute_values_for_attribute(:labels, action: "update")
  end

  def test_collection_attribute_from_callable_source
    policy = TestUserPolicy.new(TestUser.new(admin: true), TestRecord.new)
    assert_equal %w[alpha beta],
                 policy.pundit_expected_attribute_values_for_attribute(:groups, action: "update")
  end
end
