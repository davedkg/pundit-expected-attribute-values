# frozen_string_literal: true

require "pundit/expected_attribute_values/rspec"

RSpec.describe "Pundit expected value matchers" do
  let(:admin) { TestUser.new(admin: true) }
  let(:manager) { TestUser.new(manager: true) }
  let(:record) { TestRecord.new }
  let(:admin_policy) { TestUserPolicy.new(admin, record) }
  let(:manager_policy) { TestUserPolicy.new(manager, record) }

  describe "permit_expected_value" do
    it "passes for expected values" do
      expect(admin_policy).to permit_expected_value(:role, "admin")
    end

    it "fails for unexpected values" do
      expect(manager_policy).not_to permit_expected_value(:role, "admin")
    end
  end

  describe "permit_expected_values" do
    it "matches the full expected set" do
      expect(admin_policy).to permit_expected_values(:role).matching(%w[user manager admin])
    end
  end
end
