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
        filter_record!(result, @constraints)
        build_parameters(result)
      end

      private

      # Apply a set of constraints to a single record hash, filtering each
      # declared attribute in place. Undeclared keys (e.g. +id+, +_destroy+)
      # are left untouched.
      def filter_record!(record, constraints)
        constraints.each do |attribute, source|
          key = find_key(record, attribute)
          next unless key && record.key?(key)

          filter_attribute!(record, key, source)
        end
      end

      def find_key(hash, attribute)
        return attribute if hash.key?(attribute)
        return attribute.to_s if hash.key?(attribute.to_s)

        attribute.to_sym if hash.key?(attribute.to_sym)
      end

      # A literal Hash source declares nested constraints; everything else
      # (Array / Proc / Symbol) resolves to a leaf list of allowed values.
      def filter_attribute!(record, key, source)
        if source.is_a?(Hash)
          filter_nested!(record, key, source)
        else
          filter_leaf!(record, key, ValueResolver.normalize_list(ValueResolver.resolve(source, @policy)))
        end
      end

      def filter_leaf!(record, key, expected)
        value = record[key]

        if value.is_a?(Array)
          filter_array!(record, key, value, expected)
        elsif expected.include?(normalized = ValueResolver.normalize_value(value))
          record[key] = normalized
        else
          handle_unexpected(record, key, value, expected)
        end
      end

      # Validate each element of an array attribute against the allowed set.
      # Under +:raise+, any out-of-set element raises immediately; under
      # +:strip+, invalid elements are dropped and the key is removed when no
      # valid elements remain.
      def filter_array!(record, key, original, expected)
        kept = []
        original.each do |element|
          normalized = ValueResolver.normalize_value(element)
          if expected.include?(normalized)
            kept << normalized
          elsif @invalid == :raise
            raise UnexpectedValue.new(attribute: key, value: element, expected: expected)
          end
        end

        kept.empty? ? record.delete(key) : record[key] = kept
      end

      # Recurse into a nested association value (from +accepts_nested_attributes_for+).
      # Handles the array form ([{...}, {...}]), the hash-index form ({"0" => {...}})
      # keyed by index or record id (integers, UUIDs, ...), and a single record.
      def filter_nested!(record, key, nested_constraints)
        value = record[key]

        case value
        when Array
          filter_collection!(value, nested_constraints)
        when Hash
          if single_record?(value, nested_constraints)
            filter_record!(value, nested_constraints)
          else
            filter_collection!(value.values, nested_constraints)
          end
        end
      end

      def filter_collection!(records, nested_constraints)
        records.each { |child| filter_record!(child, nested_constraints) if child.is_a?(Hash) }
      end

      # Distinguish a single nested record from a hash-index collection by
      # semantics, not key format: a single record's keys are the constrained
      # attribute names, whereas a collection is keyed by record identifiers
      # (indices, integer ids, UUIDs, "new_*" placeholders, ...).
      def single_record?(value, nested_constraints)
        value.keys.any? { |k| nested_constraints.key?(k.to_sym) || nested_constraints.key?(k.to_s) }
      end

      def handle_unexpected(record, key, value, expected)
        raise UnexpectedValue.new(attribute: key, value: value, expected: expected) if @invalid == :raise

        record.delete(key)
      end

      def build_parameters(result)
        return result unless defined?(ActionController::Parameters) && @params.is_a?(ActionController::Parameters)

        filtered = ActionController::Parameters.new(result)
        # Preserve the permitted state of the source params. Callers such as the
        # +expected_attributes+ controller helper pass already-permitted params
        # (via +params.expect+); rebuilding would otherwise reset the flag and
        # raise ActiveModel::ForbiddenAttributesError on assignment.
        filtered.permit! if @params.permitted?
        filtered
      end
    end
  end
end
