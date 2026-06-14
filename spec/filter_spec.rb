# frozen_string_literal: true

RSpec.describe Pundit::ExpectedAttributeValues::Filter do
  subject(:result) { described_class.call(params, constraints, invalid: invalid, policy: policy) }

  let(:policy) { TestUserPolicy.new(TestUser.new(admin: true), TestRecord.new) }
  let(:params) { ActionController::Parameters.new(role: "admin", name: "Ada") }
  let(:constraints) { { role: %w[user admin] } }
  let(:invalid) { :strip }

  describe "scalar attributes" do
    context "when the value is expected" do
      it "keeps the value alongside other attributes" do
        expect(result[:role]).to eq("admin")
        expect(result[:name]).to eq("Ada")
      end
    end

    context "when the value is unexpected" do
      let(:constraints) { { role: %w[user] } }

      context "with :strip" do
        it "omits the attribute and keeps the rest" do
          expect(result.key?(:role)).to be false
          expect(result[:name]).to eq("Ada")
        end
      end

      context "with :raise" do
        let(:invalid) { :raise }

        it "raises UnexpectedValue with details" do
          expect { result }.to raise_error(Pundit::ExpectedAttributeValues::UnexpectedValue) do |error|
            expect(error.attribute).to eq(:role)
            expect(error.value).to eq("admin")
            expect(error.expected).to eq(%w[user])
          end
        end
      end
    end
  end

  describe "array (collection) attributes" do
    let(:params) { ActionController::Parameters.new(tags: tags) }
    let(:constraints) { { tags: %w[ruby rails pundit] } }
    let(:tags) { %w[ruby java rails] }

    context "with :strip" do
      it "keeps in-set elements and drops the rest" do
        expect(result[:tags]).to eq(%w[ruby rails])
      end

      context "with symbol elements" do
        let(:tags) { %i[ruby java] }
        let(:constraints) { { tags: %w[ruby rails] } }

        it "normalizes them against the expected set" do
          expect(result[:tags]).to eq(%w[ruby])
        end
      end

      context "when every element is unexpected" do
        let(:tags) { %w[x y] }

        it "omits the key" do
          expect(result.key?(:tags)).to be false
        end
      end

      context "when the array is empty" do
        let(:tags) { [] }

        it "omits the key" do
          expect(result.key?(:tags)).to be false
        end
      end
    end

    context "with :raise" do
      let(:invalid) { :raise }

      context "when every element is expected" do
        let(:tags) { %w[ruby rails] }

        it "keeps all elements" do
          expect(result[:tags]).to eq(%w[ruby rails])
        end
      end

      context "when any element is invalid" do
        let(:constraints) { { tags: %w[ruby rails] } }

        it "raises UnexpectedValue for the offending element" do
          expect { result }.to raise_error(Pundit::ExpectedAttributeValues::UnexpectedValue) do |error|
            expect(error.attribute).to eq(:tags)
            expect(error.value).to eq("java")
            expect(error.expected).to eq(%w[ruby rails])
          end
        end
      end
    end
  end

  describe "permitted state" do
    context "when the source params are permitted" do
      before { params.permit! }

      it { is_expected.to be_permitted }
    end

    context "when the source params are not permitted" do
      it { is_expected.not_to be_permitted }
    end
  end
end
