# frozen_string_literal: true

require "test_helper"

class FilterTest < Minitest::Test
  def setup
    @policy = TestUserPolicy.new(TestUser.new(admin: true), TestRecord.new)
    @params = ActionController::Parameters.new(role: "admin", name: "Ada")
  end

  def test_keeps_expected_scalar_values
    result = Pundit::ExpectedAttributeValues::Filter.call(
      @params,
      { role: %w[user admin] },
      invalid: :strip,
      policy: @policy
    )
    assert_equal "admin", result[:role]
    assert_equal "Ada", result[:name]
  end

  def test_omits_unexpected_scalar_values
    result = Pundit::ExpectedAttributeValues::Filter.call(
      @params,
      { role: %w[user] },
      invalid: :strip,
      policy: @policy
    )
    refute result.key?(:role)
    assert_equal "Ada", result[:name]
  end

  def test_raises_for_unexpected_scalar
    error = assert_raises(Pundit::ExpectedAttributeValues::UnexpectedValue) do
      Pundit::ExpectedAttributeValues::Filter.call(
        @params,
        { role: %w[user] },
        invalid: :raise,
        policy: @policy
      )
    end
    assert_equal :role, error.attribute
    assert_equal "admin", error.value
  end

  def test_preserves_permitted_state_of_permitted_params
    @params.permit!
    result = Pundit::ExpectedAttributeValues::Filter.call(
      @params,
      { role: %w[user admin] },
      invalid: :strip,
      policy: @policy
    )
    assert result.permitted?
  end

  def test_leaves_unpermitted_params_unpermitted
    result = Pundit::ExpectedAttributeValues::Filter.call(
      @params,
      { role: %w[user admin] },
      invalid: :strip,
      policy: @policy
    )
    refute result.permitted?
  end
end
