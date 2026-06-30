# Example app

Rails 8 app that loads [pundit-expected-attribute-values](../) from the repo
root (`path: ".."`), so it always runs against your working copy.

## Setup

```bash
cd example
bundle install
bin/rails db:setup
bin/rails server
```

Open http://localhost:3000.

## What's here

Pundit + pundit-expected-attribute-values wired in (`ApplicationController`,
`ApplicationPolicy`, and `config/initializers/pundit_expected_attribute_values.rb`).

Domain models and policy demos come next.
