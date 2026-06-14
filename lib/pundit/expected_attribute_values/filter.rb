# frozen_string_literal: true

module Pundit
  module ExpectedAttributeValues
    class Filter
      def self.call(params, constraints, invalid: ExpectedAttributeValues.invalid_behavior, policy: nil)
        new(params, constraints, invalid: invalid, policy: policy).call
      end

      def initialize(params, constraints, invalid: ExpectedAttributeValues.invalid_behavior, policy: nil)
        @params = params
        @constraints = constraints
        @invalid = invalid
        @policy = policy
      end

      def call
        return @params if @constraints.empty?

        result = @params.to_unsafe_h.dup
        @constraints.each do |attribute, source|
          key = find_key(result, attribute)
          next unless key
          next unless result.key?(key)

          expected = expected_values_for(attribute, source)
          filter_attribute!(result, key, expected)
        end

        build_parameters(result)
      end

      private

      def find_key(hash, attribute)
        return attribute if hash.key?(attribute)
        return attribute.to_s if hash.key?(attribute.to_s)
        return attribute.to_sym if hash.key?(attribute.to_sym)

        nil
      end

      def expected_values_for(_attribute, source)
        values = ValueResolver.resolve(source, @policy)
        ValueResolver.normalize_list(values)
      end

      def filter_attribute!(result, key, expected)
        value = result[key]

        if value.is_a?(Array)
          filter_array!(result, key, value, expected)
        else
          normalized = ValueResolver.normalize_value(value)
          if expected.include?(normalized)
            result[key] = normalized
          else
            handle_unexpected(result, key, value, expected)
          end
        end
      end

      # Validate each element of an array attribute against the allowed set.
      # Under +:raise+, any out-of-set element raises immediately; under
      # +:strip+, invalid elements are dropped and the key is removed when no
      # valid elements remain.
      def filter_array!(result, key, original, expected)
        kept = []
        original.each do |element|
          normalized = ValueResolver.normalize_value(element)
          if expected.include?(normalized)
            kept << normalized
          elsif @invalid == :raise
            raise UnexpectedValue.new(attribute: key, value: element, expected: expected)
          end
        end

        if kept.empty?
          result.delete(key)
        else
          result[key] = kept
        end
      end

      def handle_unexpected(result, key, value, expected)
        case @invalid
        when :raise
          raise UnexpectedValue.new(attribute: key, value: value, expected: expected)
        else
          result.delete(key)
        end
      end

      def build_parameters(result)
        if defined?(ActionController::Parameters) && @params.is_a?(ActionController::Parameters)
          filtered = ActionController::Parameters.new(result)
          # Preserve the permitted state of the source params. Callers such as
          # the +expected_attributes+ controller helper pass already-permitted
          # params (via +params.expect+); rebuilding would otherwise reset the
          # flag and raise ActiveModel::ForbiddenAttributesError on assignment.
          filtered.permit! if @params.permitted?
          filtered
        else
          result
        end
      end
    end
  end
end
