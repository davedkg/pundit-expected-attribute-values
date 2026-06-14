# frozen_string_literal: true

RSpec.describe Pundit::ExpectedAttributeValues::Policy do
  subject(:expected_values) { policy.pundit_expected_attribute_values_for_attribute(attribute, action: "update") }

  let(:record) { TestRecord.new }
  let(:user) { TestUser.new(admin: true) }
  let(:policy) { TestUserPolicy.new(user, record) }

  describe "#pundit_expected_attribute_values_for_attribute" do
    context "for the role attribute" do
      let(:attribute) { :role }

      context "when the user is an admin" do
        it { is_expected.to eq(%w[user manager admin]) }
      end

      context "when the user is a manager" do
        let(:user) { TestUser.new(manager: true) }

        it { is_expected.to eq(%w[user]) }
      end

      context "with an action-specific policy" do
        let(:policy) { TestUserUpdatePolicy.new(user, record) }

        it { is_expected.to eq(%w[user]) }
      end
    end

    context "for a collection attribute" do
      context "from a static array source" do
        let(:attribute) { :tags }

        it { is_expected.to eq(%w[ruby rails pundit]) }
      end

      context "from a method reference source" do
        let(:attribute) { :labels }

        it { is_expected.to eq(%w[bug feature chore]) }
      end

      context "from a callable source" do
        let(:attribute) { :groups }

        it { is_expected.to eq(%w[alpha beta]) }
      end
    end
  end
end
