# frozen_string_literal: true

class TestUser
  attr_reader :admin, :manager

  def initialize(admin: false, manager: false)
    @admin = admin
    @manager = manager
  end

  def admin?
    @admin
  end

  def manager?
    @manager
  end
end

class TestRecord
end

class TestUserPolicy
  include Pundit::ExpectedAttributeValues::Policy

  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def expected_attributes_for_action(_action)
    [:name, :email, :role, { tags: [], labels: [], groups: [] }]
  end

  def expected_attribute_values
    {
      role: :allowed_roles,
      tags: %w[ruby rails pundit],  # static array source
      labels: :allowed_labels,      # method reference source
      groups: -> { %w[alpha beta] } # callable source
    }
  end

  def allowed_roles
    return %w[user manager admin] if user.admin?
    return %w[user] if user.manager?

    []
  end

  def allowed_labels
    %w[bug feature chore]
  end
end

class TestUserUpdatePolicy < TestUserPolicy
  def expected_attribute_values_for_update
    { role: %w[user] }
  end
end

class TestPost
end

# Demonstrates nested-attribute constraints for accepts_nested_attributes_for.
# A Hash-valued constraint declares nested constraints (recursing to arbitrary
# depth); leaf sources stay Array/Proc/Symbol.
class TestPostPolicy
  include Pundit::ExpectedAttributeValues::Policy

  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def expected_attributes_for_action(_action)
    [:title, :status, { comments_attributes: [[:id, :body, :status, :_destroy,
                                               { author_attributes: %i[id name role] }]] }]
  end

  def expected_attribute_values
    {
      status: %w[draft published],
      comments_attributes: {
        status: %w[visible hidden],
        author_attributes: { role: %w[member moderator] }
      }
    }
  end
end
