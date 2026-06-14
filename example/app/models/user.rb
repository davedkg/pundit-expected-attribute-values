# The signed-in actor. Their role drives which attribute values a policy allows.
class User < ApplicationRecord
  ROLES = %w[member editor admin].freeze

  has_many :posts, dependent: :destroy
end
