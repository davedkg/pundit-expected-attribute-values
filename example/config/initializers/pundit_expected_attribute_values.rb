Pundit::ExpectedAttributeValues.configure do |config|
  # :strip (default) silently drops out-of-set values during mass assignment.
  # Switch to :raise to instead raise Pundit::ExpectedAttributeValues::UnexpectedValue
  # (ApplicationController rescues it and renders the 422 page) — handy for
  # seeing exactly which value was rejected.
  config.invalid_behavior = :strip
  # config.invalid_behavior = :raise
end
