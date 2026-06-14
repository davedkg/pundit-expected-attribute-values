# pundit-expected-attribute-values

[![Gem](https://github.com/davedkg/pundit-expected-attribute-values/actions/workflows/gem.yml/badge.svg)](https://github.com/davedkg/pundit-expected-attribute-values/actions/workflows/gem.yml)
[![Gem Version](https://badge.fury.io/rb/pundit-expected-attribute-values.svg)](https://badge.fury.io/rb/pundit-expected-attribute-values)

Expected **values** for [Pundit](https://github.com/varvet/pundit) strong parameters. Works with Pundit 2.6+ `expected_attributes` / `expected_attributes_for_action` and Rails `params.expect`.

Declare which values each attribute may have during mass assignment (for example, admins may set `role` to `manager` or `user`, while managers may only set `role` to `user`). Attributes may be **scalar or array (collection)** — for an array attribute, each submitted element is validated against the allowed set.

Keys stay in `expected_attributes_for_action`; allowed values live in `expected_attribute_values_for_action`.

## Requirements

- Ruby >= 3.3
- Pundit >= 2.5 (ships a compatibility shim for `expected_attributes` until Pundit 2.6 is released)
- Rails >= 7.0 (uses `params.expect`)

## Installation

```ruby
gem "pundit-expected-attribute-values"
```

```bash
bundle install
rails generate pundit:expected_attribute_values:install
```

### Manual setup

```ruby
# app/policies/application_policy.rb
class ApplicationPolicy
  include Pundit::ExpectedAttributeValues::Policy
end

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pundit::ExpectedAttributeValues::Authorization
end
```

## Example app

A runnable Rails app demonstrating scalar, collection, and nested constraints —
plus the form-values helper and `:strip`/`:raise` — lives in [`example/`](example/).
See [example/README.md](example/README.md) to run it and its policy specs.

## Usage

### Policy

```ruby
class UserPolicy < ApplicationPolicy
  def expected_attributes_for_action(_action)
    [:name, :email, :role]
  end

  def expected_attribute_values_for_action(_action)
    { role: :allowed_roles }
  end

  private

  def allowed_roles
    return %w[user manager admin] if user.admin?
    return %w[user] if user.manager?

    []
  end
end
```

Action-specific value rules (optional):

```ruby
def expected_attribute_values_for_update
  { role: %w[user] }
end
```

Value sources: static arrays, callables (`-> { ... }`), or method references (`:allowed_roles`).

### Collection (array) attributes

An attribute submitted as an array (e.g. a multi-select like `tag_ids` or `roles[]`) is validated element by element against the same allowed set:

```ruby
class ArticlePolicy < ApplicationPolicy
  def expected_attributes_for_action(_action)
    [:title, { tags: [] }] # keys: declare the array shape for params.expect
  end

  def expected_attribute_values_for_action(_action)
    { tags: %w[ruby rails pundit] } # allowed values for each element
  end
end
```

Given `params` of `tags: %w[ruby java rails]`:

- with `invalid_behavior = :strip` (default), out-of-set elements are dropped — `tags` becomes `%w[ruby rails]` (the key is omitted entirely if no elements remain).
- with `invalid_behavior = :raise`, any out-of-set element raises `Pundit::ExpectedAttributeValues::UnexpectedValue`.

### Nested attributes (`accepts_nested_attributes_for`)

Constraints can reach into nested records. Declare a constraint value as a **`Hash`** to describe the nested record's fields; it recurses to arbitrary depth. Leaf values stay `Array` / `Proc` / `Symbol` as usual.

```ruby
class PostPolicy < ApplicationPolicy
  def expected_attributes_for_action(_action)
    # keys: the usual nested strong-params shape for params.expect
    [:title, :status, { comments_attributes: [[:id, :body, :status, :_destroy,
                                               { author_attributes: [:id, :name, :role] }]] }]
  end

  def expected_attribute_values_for_action(_action)
    {
      status: %w[draft published],
      comments_attributes: {           # Hash ⇒ nested constraints (recurses)
        status: %w[visible hidden],
        author_attributes: {           # deeper nesting
          role: :allowed_comment_roles # leaf source still resolves via the policy
        }
      }
    }
  end

  private

  def allowed_comment_roles
    %w[member moderator]
  end
end
```

Each nested record's declared fields are validated the same way scalars and arrays are. The filter handles the array form (`comments_attributes: [{…}, {…}]`), the hash-index form (`comments_attributes: {"0" => {…}}`, keyed by index or record id — integers, UUIDs, etc.), and a single nested record (`author_attributes: {…}`).

Undeclared keys — including `id` and `_destroy` — **pass through untouched**; only fields you constrain are filtered. `:strip` drops invalid nested values, `:raise` raises on the first one.

> **Nested constraints must be a literal `Hash`.** The nesting is detected from the declared value's type, _before_ `Proc`/`Symbol` sources are resolved — so a callable or method reference that *returns* a `Hash` is treated as a leaf, not as nesting. Hardcode the nested shape and use `Proc`/`Symbol` only at the leaves (as `role:` does above):
>
> ```ruby
> comments_attributes: { status: %w[visible hidden] }      # ✅ nested
> comments_attributes: -> { { status: %w[visible hidden] } } # ❌ treated as a leaf, not nesting
> ```

### Controller

```ruby
def update
  authorize @user
  if @user.update(expected_attributes(@user))
    redirect_to @user
  else
    render :edit
  end
end
```

Allowed values for forms or APIs:

```ruby
pundit_expected_attribute_values_for(@user, :role)
# => ["user", "manager"]
```

### Unexpected values

```ruby
# config/initializers/pundit-expected-attribute-values.rb
Pundit::ExpectedAttributeValues.configure do |config|
  config.invalid_behavior = :strip # default — omit unexpected values
  # config.invalid_behavior = :raise
end
```

With `:raise`, unexpected values raise `Pundit::ExpectedAttributeValues::UnexpectedValue`:

```ruby
rescue_from Pundit::ExpectedAttributeValues::UnexpectedValue, with: :unprocessable
```

### Manual filtering

```ruby
attrs = expected_attributes(@user)
# or on an extracted hash:
Pundit::ExpectedAttributeValues.filter(attrs, policy(@user), action: "update")
```

## Testing

### RSpec

```ruby
# spec/support/pundit-expected-attribute-values.rb
require "pundit/expected_attribute_values/rspec"

expect(user_policy).to permit_expected_value(:role, "user")
expect(user_policy).not_to permit_expected_value(:role, "admin")
expect(user_policy).to permit_expected_values(:role).matching(%w[user manager])
```

### Minitest

```ruby
require "pundit/expected_attribute_values/minitest"

assert_permits_expected_value user_policy, :role, "user"
refute_permits_expected_value user_policy, :role, "admin"
assert_expected_values user_policy, :role, %w[user manager]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Releasing

1. Update the version in `lib/pundit/expected_attribute_values/version.rb`.
2. Add a dated section to [CHANGELOG.md](CHANGELOG.md).
3. Commit, tag (`git tag vX.Y.Z`), and push the tag.
4. GitHub Actions publishes the gem to [RubyGems](https://rubygems.org) when a `v*` tag is pushed. Configure [trusted publishing](https://guides.rubygems.org/trusted-publishing/) on RubyGems.org for this repository (recommended), or publish locally with `bundle exec rake release` after configuring RubyGems credentials.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
