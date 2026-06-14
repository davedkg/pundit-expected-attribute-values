require "test_helper"

# Policy-only tests demonstrating the gem's Minitest assertions
# (assert_permits_expected_value / refute_permits_expected_value /
# assert_expected_values). Models are unsaved, so no database rows are needed;
# allowed values change with the user's role.
class PostPolicyTest < ActiveSupport::TestCase
  include Pundit::ExpectedAttributeValues::MinitestAssertions

  def policy_for(role)
    PostPolicy.new(User.new(role: role), Post.new)
  end

  # status (scalar value)
  test "member may set only draft" do
    assert_expected_values policy_for("member"), :status, %w[draft]
  end

  test "editor may set draft and published" do
    assert_expected_values policy_for("editor"), :status, %w[draft published]
  end

  test "admin may set archived" do
    assert_permits_expected_value policy_for("admin"), :status, "archived"
  end

  test "member may not set published" do
    refute_permits_expected_value policy_for("member"), :status, "published"
  end

  # tags (collection value)
  test "member may not tag security" do
    refute_permits_expected_value policy_for("member"), :tags, "security"
  end

  test "editor may tag security" do
    assert_permits_expected_value policy_for("editor"), :tags, "security"
  end
end
