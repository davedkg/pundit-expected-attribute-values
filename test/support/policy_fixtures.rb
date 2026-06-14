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
    %i[name email role]
  end

  def expected_attribute_values
    { role: :allowed_roles }
  end

  def allowed_roles
    return %w[user manager admin] if user.admin?
    return %w[user] if user.manager?

    []
  end
end

class TestUserUpdatePolicy < TestUserPolicy
  def expected_attribute_values_for_update
    { role: %w[user] }
  end
end
