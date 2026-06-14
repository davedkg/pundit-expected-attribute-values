# frozen_string_literal: true

module Pundit
  module ExpectedAttributeValues
    class << self
      attr_accessor :invalid_behavior, :symbolize_values

      def configure
        yield self if block_given?
        self
      end
    end

    self.invalid_behavior = :strip
    self.symbolize_values = false
  end
end
