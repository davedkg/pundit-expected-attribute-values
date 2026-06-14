# A comment's author. Edited through deeply nested attributes
# (post ▸ comments_attributes ▸ author_attributes).
class Author < ApplicationRecord
  ROLES = %w[guest member moderator].freeze

  has_many :comments, dependent: :destroy
end
