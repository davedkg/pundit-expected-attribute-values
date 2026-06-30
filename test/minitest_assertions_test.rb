# frozen_string_literal: true

require "test_helper"
require "pundit/expected_attribute_values/minitest"

class MinitestAssertionsTest < Minitest::Test
  def setup
    @admin_policy = TestUserPolicy.new(TestUser.new(admin: true), TestRecord.new)
    @manager_policy = TestUserPolicy.new(TestUser.new(manager: true), TestRecord.new)
  end

  def test_assert_permits_expected_value
    assert_permits_expected_value @admin_policy, :role, "admin"
  end

  def test_refute_permits_expected_value
    refute_permits_expected_value @manager_policy, :role, "admin"
  end

  def test_assert_expected_values
    assert_expected_values @admin_policy, :role, %w[user manager admin]
  end

  def test_assert_permits_collection_element
    assert_permits_expected_value @admin_policy, :tags, "ruby"
  end

  def test_refute_permits_collection_element
    refute_permits_expected_value @admin_policy, :tags, "java"
  end

  def test_assert_expected_values_for_collection
    assert_expected_values @admin_policy, :tags, %w[ruby rails pundit]
  end
end
