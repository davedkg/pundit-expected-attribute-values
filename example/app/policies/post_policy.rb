# Demonstrates every tier of the gem in one policy:
#   * scalar value      -> :status
#   * collection (array) -> :tags
#   * nested attributes  -> :comments_attributes (and the deeper :author_attributes)
#
# Allowed values vary by the signed-in user's role, so signing in as a
# different user changes what mass assignment will accept.
class PostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present?
  end

  def update?
    user.present?
  end

  # Strong-parameter *keys* (the shape passed to params.expect).
  def expected_attributes_for_action(_action)
    [ :title, :status, { tags: [],
                        comments_attributes: [ [ :id, :body, :status, :_destroy,
                                               { author_attributes: [ :id, :name, :role ] } ] ] } ]
  end

  # Allowed *values* for those keys. A Hash value declares nested constraints.
  def expected_attribute_values_for_action(_action)
    {
      status: allowed_statuses,
      tags: allowed_tags,
      comments_attributes: {
        status: Comment::STATUSES,
        author_attributes: { role: allowed_author_roles }
      }
    }
  end

  private

  def allowed_statuses
    case user.role
    when "admin" then %w[draft published archived]
    when "editor" then %w[draft published]
    else %w[draft]
    end
  end

  def allowed_tags
    return Post::TAGS if user.role.in?(%w[admin editor])

    Post::TAGS - %w[security performance]
  end

  def allowed_author_roles
    return Author::ROLES if user.role == "admin"

    Author::ROLES - %w[moderator]
  end
end
