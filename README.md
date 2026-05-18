# pundit-expected-attribute-values

Expected **values** for [Pundit](https://github.com/varvet/pundit) strong parameters. Works with Pundit 2.6+ `expected_attributes` / `expected_attributes_for_action` and Rails `params.expect`.

Declare which scalar values each attribute may have during mass assignment (for example, admins may set `role` to `manager` or `user`, while managers may only set `role` to `user`).

Keys stay in `expected_attributes_for_action`; allowed values live in `expected_attribute_values_for_action`.

## Requirements

- Ruby >= 3.2
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

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davedkg/pundit-expected-attribute-values.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
