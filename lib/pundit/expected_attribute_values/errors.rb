# frozen_string_literal: true

module Pundit
  module ExpectedAttributeValues
    class UnexpectedValue < Pundit::NotAuthorizedError
      attr_reader :attribute, :value, :expected

      def initialize(attribute:, value:, expected:)
        @attribute = attribute
        @value = value
        @expected = expected
        super(
          "Value #{value.inspect} is not expected for #{attribute}; " \
          "expected: #{expected.inspect}"
        )
      end
    end
  end
end
