# Example app: pundit-expected-attribute-values

A tiny, vanilla Rails 8 blog that demonstrates
[pundit-expected-attribute-values](../) end to end. It loads the gem from the
repo root (`gem "...", path: ".."`), so it always exercises your working copy.

## What it demonstrates

| Tier | Where | Attribute |
|------|-------|-----------|
| **Scalar value** | `PostPolicy` | `Post#status` (`draft` / `published` / `archived`) |
| **Collection (array) value** | `PostPolicy` | `Post#tags` |
| **Nested attributes** | `PostPolicy` | `comments_attributes ▸ status` and the deeper `author_attributes ▸ role` |
| **Form-values helper** | `posts/_form.html.erb` | `pundit_expected_attribute_values_for(post, :status)` / `:tags` populate the form controls |
| **`:strip` vs `:raise`** | initializer + `ApplicationController` | see below |

Allowed values vary by the signed-in user's **role**, so signing in as a
different user changes what mass assignment accepts. The whole point lives in
[`app/policies/post_policy.rb`](app/policies/post_policy.rb).

## Setup

```bash
cd example
bundle install
bin/rails db:setup   # create, schema-load, seed
bin/rails server
```

Open http://localhost:3000. You'll land on the user picker.

## Try it

1. **Sign in** as *Mia Member*.
2. **New post** — note the **Status** dropdown only offers `draft`, and the
   **Tags** list omits `security` / `performance` (the policy restricts them for
   members). The nested comment form lists every author role, but…
3. Submit with a comment whose **author role = moderator**. After saving, open
   the post: the author's role is blank — the policy **stripped** the value a
   member isn't allowed to set.
4. **Sign out**, sign in as *Ada Admin*, and repeat: `archived`, `security`, and
   `moderator` are all allowed now.

## `:strip` vs `:raise`

`config/initializers/pundit_expected_attribute_values.rb` sets the default,
`:strip` (out-of-set values are silently dropped). Flip it to `:raise`:

```ruby
config.invalid_behavior = :raise
```

Now submitting an out-of-set value raises
`Pundit::ExpectedAttributeValues::UnexpectedValue`; `ApplicationController`
rescues it and renders a 422 page showing the rejected attribute and value.

## Tests (Pundit policies only)

The gem ships both RSpec matchers and Minitest assertions; this app uses each to
test the same policy. There are **no** model/controller/system tests here.

```bash
bundle exec rspec spec/policies     # RSpec matchers
bin/rails test test/policies        # Minitest assertions
```

Both suites run in CI (see `.github/workflows/example.yml` at the repo root).
