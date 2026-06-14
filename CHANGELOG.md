# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-06-13

### Added

- Per-attribute allowed values for Pundit `expected_attributes`, declared in policy classes via `expected_attribute_values_for_action` and action-specific helpers such as `expected_attribute_values_for_update`.
- Controller integration through `Pundit::ExpectedAttributeValues::Authorization`, including `expected_attributes` value filtering and `pundit_expected_attribute_values_for`.
- `Pundit::ExpectedAttributeValues.filter` for manual filtering of permitted params or plain hashes.
- Configurable invalid-value behavior (`:strip` or `:raise`) via `Pundit::ExpectedAttributeValues.configure`.
- `Pundit::ExpectedAttributeValues::UnexpectedValue` exception when `invalid_behavior` is `:raise`.
- Value sources: static arrays, callables, and method references resolved through the policy instance.
- RSpec matchers (`permit_expected_value`, `permit_expected_values`) and Minitest assertions.
- Rails install generator: `rails generate pundit:expected_attribute_values:install`.
- Compatibility shim for Pundit 2.5 controllers that do not yet ship `expected_attributes`.

### Fixed

- Preserve the permitted state of `ActionController::Parameters` when filtering already-permitted params from `params.expect`, avoiding `ActiveModel::ForbiddenAttributesError` on assignment.

[1.0.0]: https://github.com/davedkg/pundit-expected-attribute-values/releases/tag/v1.0.0
