# frozen_string_literal: true

RSpec.describe Pundit::ExpectedAttributeValues::Authorization do
  subject(:filtered) { controller.expected_attributes(record) }

  let(:record) { TestRecord.new }
  let(:user) { TestUser.new(manager: true) }
  let(:policy) { TestUserPolicy.new(user, record) }
  let(:submitted) { { name: "Ada", role: "manager" } }

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
      c.params = ActionController::Parameters.new(test_record: submitted)
      c.policy_instance = policy
    end
  end

  around do |example|
    original = Pundit::ExpectedAttributeValues.invalid_behavior
    example.run
    Pundit::ExpectedAttributeValues.invalid_behavior = original
  end

  describe "#expected_attributes" do
    context "with :strip" do
      before { Pundit::ExpectedAttributeValues.invalid_behavior = :strip }

      context "with an unexpected scalar value" do
        it "filters values after params extraction" do
          expect(filtered[:name]).to eq("Ada")
          expect(filtered.key?(:role)).to be false
        end
      end

      context "with an array attribute" do
        let(:submitted) { { name: "Ada", tags: %w[ruby java rails] } }

        it "filters elements to the expected set" do
          expect(filtered[:name]).to eq("Ada")
          expect(filtered[:tags]).to eq(%w[ruby rails])
        end
      end
    end

    context "with :raise" do
      before { Pundit::ExpectedAttributeValues.invalid_behavior = :raise }

      context "with an unexpected scalar value" do
        it "raises UnexpectedValue" do
          expect { filtered }.to raise_error(Pundit::ExpectedAttributeValues::UnexpectedValue)
        end
      end

      context "with an invalid array element" do
        let(:submitted) { { name: "Ada", tags: %w[ruby java] } }

        it "raises UnexpectedValue for the offending element" do
          expect { filtered }.to raise_error(Pundit::ExpectedAttributeValues::UnexpectedValue) do |error|
            expect(error.attribute).to eq(:tags)
            expect(error.value).to eq("java")
          end
        end
      end
    end
  end

  describe "#pundit_expected_attribute_values_for" do
    let(:user) { TestUser.new(admin: true) }

    it "delegates to the policy" do
      expect(controller.pundit_expected_attribute_values_for(record, :role)).to eq(%w[user manager admin])
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
