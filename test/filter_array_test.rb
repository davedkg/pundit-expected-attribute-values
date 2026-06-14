# frozen_string_literal: true

require "test_helper"

class FilterArrayTest < Minitest::Test
  def setup
    @policy = TestUserPolicy.new(TestUser.new(admin: true), TestRecord.new)
  end

  def test_keeps_expected_array_elements_and_drops_the_rest
    params = ActionController::Parameters.new(tags: %w[ruby java rails])
    result = Pundit::ExpectedAttributeValues::Filter.call(
      params,
      { tags: %w[ruby rails pundit] },
      invalid: :strip,
      policy: @policy
    )
    assert_equal %w[ruby rails], result[:tags]
  end

  def test_normalizes_symbol_array_elements
    params = ActionController::Parameters.new(tags: %i[ruby java])
    result = Pundit::ExpectedAttributeValues::Filter.call(
      params,
      { tags: %w[ruby rails] },
      invalid: :strip,
      policy: @policy
    )
    assert_equal %w[ruby], result[:tags]
  end

  def test_omits_array_key_when_all_elements_unexpected
    params = ActionController::Parameters.new(tags: %w[x y])
    result = Pundit::ExpectedAttributeValues::Filter.call(
      params,
      { tags: %w[ruby] },
      invalid: :strip,
      policy: @policy
    )
    refute result.key?(:tags)
  end

  def test_omits_array_key_when_submitted_array_empty
    params = ActionController::Parameters.new(tags: [])
    result = Pundit::ExpectedAttributeValues::Filter.call(
      params,
      { tags: %w[ruby] },
      invalid: :strip,
      policy: @policy
    )
    refute result.key?(:tags)
  end

  def test_keeps_array_when_all_elements_expected_with_raise
    params = ActionController::Parameters.new(tags: %w[ruby rails])
    result = Pundit::ExpectedAttributeValues::Filter.call(
      params,
      { tags: %w[ruby rails pundit] },
      invalid: :raise,
      policy: @policy
    )
    assert_equal %w[ruby rails], result[:tags]
  end

  def test_raises_on_any_invalid_array_element
    error = assert_raises(Pundit::ExpectedAttributeValues::UnexpectedValue) do
      Pundit::ExpectedAttributeValues::Filter.call(
        ActionController::Parameters.new(tags: %w[ruby java rails]),
        { tags: %w[ruby rails] },
        invalid: :raise,
        policy: @policy
      )
    end
    assert_equal :tags, error.attribute
    assert_equal "java", error.value
  end
end
