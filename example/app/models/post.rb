class Post < ApplicationRecord
  STATUSES = %w[draft published archived].freeze
  # Demonstrates a collection (array) attribute.
  TAGS = %w[ruby rails pundit security performance].freeze

  belongs_to :user
  has_many :comments, dependent: :destroy

  # Demonstrates nested attributes (accepts_nested_attributes_for).
  accepts_nested_attributes_for :comments, allow_destroy: true,
                                           reject_if: ->(attrs) { attrs["body"].blank? }

  # Array attribute stored as JSON so SQLite can hold the collection.
  serialize :tags, type: Array, coder: JSON
end
