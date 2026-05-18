# frozen_string_literal: true

RSpec.describe Pundit::ExpectedAttributeValues::Filter do
  let(:policy) { TestUserPolicy.new(TestUser.new(admin: true), TestRecord.new) }
  let(:params) { ActionController::Parameters.new(role: "admin", name: "Ada") }

  describe ".call with :strip" do
    it "keeps expected scalar values" do
      result = described_class.call(params, { role: %w[user admin] }, invalid: :strip, policy: policy)
      expect(result[:role]).to eq("admin")
      expect(result[:name]).to eq("Ada")
    end

    it "omits unexpected scalar values" do
      result = described_class.call(params, { role: %w[user] }, invalid: :strip, policy: policy)
      expect(result.key?(:role)).to be false
      expect(result[:name]).to eq("Ada")
    end

    it "filters array values to expected elements" do
      array_params = ActionController::Parameters.new(tags: %w[a b c])
      result = described_class.call(
        array_params,
        { tags: %w[a c] },
        invalid: :strip,
        policy: policy
      )
      expect(result[:tags]).to eq(%w[a c])
    end

    it "omits array key when all elements are unexpected" do
      array_params = ActionController::Parameters.new(tags: %w[x y])
      result = described_class.call(
        array_params,
        { tags: %w[a] },
        invalid: :strip,
        policy: policy
      )
      expect(result.key?(:tags)).to be false
    end
  end

  describe ".call with :raise" do
    it "raises UnexpectedValue for unexpected scalar" do
      expect do
        described_class.call(params, { role: %w[user] }, invalid: :raise, policy: policy)
      end.to raise_error(Pundit::ExpectedAttributeValues::UnexpectedValue) do |error|
        expect(error.attribute).to eq(:role)
        expect(error.value).to eq("admin")
        expect(error.expected).to eq(%w[user])
      end
    end
  end
end
