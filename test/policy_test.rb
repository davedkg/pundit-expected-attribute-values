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
end
