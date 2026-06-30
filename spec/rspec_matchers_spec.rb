# frozen_string_literal: true

require "pundit/expected_attribute_values/rspec"

RSpec.describe "Pundit expected value matchers" do
  subject(:policy) { TestUserPolicy.new(user, TestRecord.new) }

  let(:user) { TestUser.new(admin: true) }

  describe "permit_expected_value" do
    context "for a scalar attribute" do
      it { is_expected.to permit_expected_value(:role, "admin") }

      context "when the user is a manager" do
        let(:user) { TestUser.new(manager: true) }

        it { is_expected.not_to permit_expected_value(:role, "admin") }
      end
    end

    context "for a collection attribute" do
      it { is_expected.to permit_expected_value(:tags, "ruby") }
      it { is_expected.not_to permit_expected_value(:tags, "java") }
    end
  end

  describe "permit_expected_values" do
    it { is_expected.to permit_expected_values(:role).matching(%w[user manager admin]) }
    it { is_expected.to permit_expected_values(:tags).matching(%w[ruby rails pundit]) }
  end
end
