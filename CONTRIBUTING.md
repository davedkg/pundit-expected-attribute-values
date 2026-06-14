# Contributing

Thanks for your interest in contributing to **pundit-expected-attribute-values**.

## Development setup

```bash
git clone https://github.com/davedkg/pundit-expected-attribute-values.git
cd pundit-expected-attribute-values
bin/setup
bundle exec rake
```

`bin/setup` installs dependencies. `bundle exec rake` runs Minitest, RSpec, and is the default task.

## Pull requests

1. Open an issue first for substantial changes so we can agree on the approach.
2. Add or update tests for the behavior you change.
3. Run the full test suite and RuboCop before opening a PR:

   ```bash
   bundle exec rake
   bundle exec rubocop
   ```

4. Keep commits focused and write clear commit messages.

## Reporting bugs

Open a [GitHub issue](https://github.com/davedkg/pundit-expected-attribute-values/issues) with:

- Ruby, Rails, Pundit, and gem versions
- Steps to reproduce
- Expected vs. actual behavior

## Code of conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). By participating, you agree to uphold it.
