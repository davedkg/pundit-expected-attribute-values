class Comment < ApplicationRecord
  STATUSES = %w[visible hidden flagged].freeze

  belongs_to :post
  belongs_to :author

  # Deeper nesting: a comment's author is edited via author_attributes.
  accepts_nested_attributes_for :author
end
