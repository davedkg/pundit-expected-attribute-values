# frozen_string_literal: true

require "test_helper"

class FilterNestedTest < Minitest::Test
  def setup
    @policy = TestPostPolicy.new(TestUser.new(admin: true), TestPost.new)
    @constraints = {
      comments_attributes: {
        status: %w[visible hidden],
        author_attributes: { role: %w[member moderator] }
      }
    }
  end

  def filter(params, invalid: :strip, constraints: @constraints)
    Pundit::ExpectedAttributeValues::Filter.call(params, constraints, invalid: invalid, policy: @policy)
  end

  def test_array_form_filters_each_record
    params = ActionController::Parameters.new(
      comments_attributes: [{ body: "keep", status: "spam" }, { status: "hidden" }]
    )
    result = filter(params)
    refute result[:comments_attributes][0].key?(:status)
    assert_equal "keep", result[:comments_attributes][0][:body]
    assert_equal "hidden", result[:comments_attributes][1][:status]
  end

  def test_numeric_hash_index_form
    params = ActionController::Parameters.new(
      comments_attributes: { "0" => { status: "spam" }, "1" => { status: "visible" } }
    )
    result = filter(params)
    refute result[:comments_attributes]["0"].key?(:status)
    assert_equal "visible", result[:comments_attributes]["1"][:status]
  end

  def test_uuid_hash_index_form
    uuid = "550e8400-e29b-41d4-a716-446655440000"
    params = ActionController::Parameters.new(comments_attributes: { uuid => { status: "spam" } })
    result = filter(params)
    refute result[:comments_attributes][uuid].key?(:status)
  end

  def test_single_nested_record
    params = ActionController::Parameters.new(author_attributes: { name: "Ada", role: "hacker" })
    result = filter(params, constraints: { author_attributes: { role: %w[member moderator] } })
    refute result[:author_attributes].key?(:role)
    assert_equal "Ada", result[:author_attributes][:name]
  end

  def test_arbitrary_depth
    params = ActionController::Parameters.new(
      comments_attributes: [{ status: "visible", author_attributes: { name: "Ada", role: "hacker" } }]
    )
    result = filter(params)
    assert_equal "visible", result[:comments_attributes][0][:status]
    refute result[:comments_attributes][0][:author_attributes].key?(:role)
    assert_equal "Ada", result[:comments_attributes][0][:author_attributes][:name]
  end

  def test_passes_through_id_and_destroy
    params = ActionController::Parameters.new(
      comments_attributes: [{ id: "abc", _destroy: "1", status: "spam" }]
    )
    result = filter(params)
    assert_equal "abc", result[:comments_attributes][0][:id]
    assert_equal "1", result[:comments_attributes][0][:_destroy]
    refute result[:comments_attributes][0].key?(:status)
  end

  def test_raise_on_invalid_nested_value
    params = ActionController::Parameters.new(comments_attributes: [{ status: "spam" }])
    error = assert_raises(Pundit::ExpectedAttributeValues::UnexpectedValue) do
      filter(params, invalid: :raise)
    end
    assert_equal :status, error.attribute
    assert_equal "spam", error.value
  end
end
