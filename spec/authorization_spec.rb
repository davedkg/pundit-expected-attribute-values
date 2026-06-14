# frozen_string_literal: true

RSpec.describe Pundit::ExpectedAttributeValues::Authorization do
  let(:manager) { TestUser.new(manager: true) }
  let(:record) { TestRecord.new }
  let(:policy) { TestUserPolicy.new(manager, record) }

  let(:controller_class) do
    Class.new do
      include Pundit::ExpectedAttributeValues::Authorization

      attr_accessor :params, :policy_instance

      def action_name
        "update"
      end

      def policy(_record)
        policy_instance
      end
    end
  end

  let(:controller) do
    controller_class.new.tap do |c|
      c.params = ActionController::Parameters.new(
        test_record: { name: "Ada", role: "manager" }
      )
      c.policy_instance = policy
    end
  end

  describe "#pundit_expected_attribute_values_for" do
    it "delegates to the policy" do
      admin_policy = TestUserPolicy.new(TestUser.new(admin: true), record)
      controller.policy_instance = admin_policy
      expect(controller.pundit_expected_attribute_values_for(record, :role)).to eq(%w[user manager admin])
    end
  end

  describe "#expected_attributes" do
    it "filters values after params extraction" do
      Pundit::ExpectedAttributeValues.invalid_behavior = :strip
      result = controller.expected_attributes(record)
      expect(result[:name]).to eq("Ada")
      expect(result.key?(:role)).to be false
    end

    it "raises when configured with :raise" do
      Pundit::ExpectedAttributeValues.invalid_behavior = :raise
      expect { controller.expected_attributes(record) }
        .to raise_error(Pundit::ExpectedAttributeValues::UnexpectedValue)
    ensure
      Pundit::ExpectedAttributeValues.invalid_behavior = :strip
    end
  end

  describe ".filter" do
    it "filters a hash using policy constraints" do
      params = ActionController::Parameters.new(role: "user")
      result = described_class.filter(params, policy, action: "update")
      expect(result[:role]).to eq("user")
    end
  end
end
