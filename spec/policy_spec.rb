# frozen_string_literal: true

RSpec.describe Pundit::ExpectedAttributeValues::Policy do
  let(:admin) { TestUser.new(admin: true) }
  let(:manager) { TestUser.new(manager: true) }
  let(:record) { TestRecord.new }

  describe "#pundit_expected_attribute_values_for_attribute" do
    it "returns expected roles for admin" do
      policy = TestUserPolicy.new(admin, record)
      expect(policy.pundit_expected_attribute_values_for_attribute(:role, action: "update")).to eq(
        %w[user manager admin]
      )
    end

    it "returns restricted roles for manager" do
      policy = TestUserPolicy.new(manager, record)
      expect(policy.pundit_expected_attribute_values_for_attribute(:role, action: "update")).to eq(%w[user])
    end

    it "uses action-specific values when defined" do
      policy = TestUserUpdatePolicy.new(admin, record)
      expect(policy.pundit_expected_attribute_values_for_attribute(:role, action: "update")).to eq(%w[user])
    end

    it "resolves a collection attribute from a static array source" do
      policy = TestUserPolicy.new(admin, record)
      expect(policy.pundit_expected_attribute_values_for_attribute(:tags, action: "update")).to eq(
        %w[ruby rails pundit]
      )
    end

    it "resolves a collection attribute from a method reference source" do
      policy = TestUserPolicy.new(admin, record)
      expect(policy.pundit_expected_attribute_values_for_attribute(:labels, action: "update")).to eq(
        %w[bug feature chore]
      )
    end

    it "resolves a collection attribute from a callable source" do
      policy = TestUserPolicy.new(admin, record)
      expect(policy.pundit_expected_attribute_values_for_attribute(:groups, action: "update")).to eq(
        %w[alpha beta]
      )
    end
  end
end
