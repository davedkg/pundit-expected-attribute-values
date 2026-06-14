# frozen_string_literal: true

RSpec.describe Pundit::ExpectedAttributeValues::Filter, "with nested attributes" do
  subject(:result) { described_class.call(params, constraints, invalid: invalid, policy: policy) }

  let(:policy) { TestPostPolicy.new(TestUser.new(admin: true), TestPost.new) }
  let(:invalid) { :strip }
  let(:constraints) do
    {
      comments_attributes: {
        status: %w[visible hidden],
        author_attributes: { role: %w[member moderator] }
      }
    }
  end

  describe "array form" do
    let(:params) do
      ActionController::Parameters.new(
        comments_attributes: [
          { body: "keep me", status: "spam" },
          { body: "fine", status: "hidden" }
        ]
      )
    end

    it "strips an invalid nested value" do
      expect(result[:comments_attributes][0].key?(:status)).to be false
    end

    it "keeps a valid nested value" do
      expect(result[:comments_attributes][1][:status]).to eq("hidden")
    end

    it "leaves undeclared nested fields untouched" do
      expect(result[:comments_attributes][0][:body]).to eq("keep me")
    end
  end

  describe "hash-index form with numeric keys" do
    let(:params) do
      ActionController::Parameters.new(
        comments_attributes: { "0" => { status: "spam" }, "1" => { status: "visible" } }
      )
    end

    it "strips the invalid record's value" do
      expect(result[:comments_attributes]["0"].key?(:status)).to be false
    end

    it "keeps the valid record's value" do
      expect(result[:comments_attributes]["1"][:status]).to eq("visible")
    end
  end

  describe "hash-index form with UUID keys" do
    let(:uuid) { "550e8400-e29b-41d4-a716-446655440000" }
    let(:params) do
      ActionController::Parameters.new(comments_attributes: { uuid => { status: "spam" } })
    end

    it "strips the invalid value regardless of key format" do
      expect(result[:comments_attributes][uuid].key?(:status)).to be false
    end
  end

  describe "single nested record" do
    let(:constraints) { { author_attributes: { role: %w[member moderator] } } }
    let(:params) do
      ActionController::Parameters.new(author_attributes: { name: "Ada", role: "hacker" })
    end

    it "strips the invalid nested value" do
      expect(result[:author_attributes].key?(:role)).to be false
    end

    it "leaves undeclared nested fields untouched" do
      expect(result[:author_attributes][:name]).to eq("Ada")
    end
  end

  describe "arbitrary depth" do
    let(:params) do
      ActionController::Parameters.new(
        comments_attributes: [
          { status: "visible", author_attributes: { name: "Ada", role: "hacker" } }
        ]
      )
    end

    it "keeps the valid value at the shallow level" do
      expect(result[:comments_attributes][0][:status]).to eq("visible")
    end

    it "strips the invalid value at the deep level" do
      expect(result[:comments_attributes][0][:author_attributes].key?(:role)).to be false
    end

    it "leaves undeclared deep fields untouched" do
      expect(result[:comments_attributes][0][:author_attributes][:name]).to eq("Ada")
    end
  end

  describe "pass-through keys" do
    let(:params) do
      ActionController::Parameters.new(
        comments_attributes: [{ id: "550e8400-e29b-41d4-a716-446655440000", _destroy: "1", status: "spam" }]
      )
    end

    it "preserves id" do
      expect(result[:comments_attributes][0][:id]).to eq("550e8400-e29b-41d4-a716-446655440000")
    end

    it "preserves _destroy" do
      expect(result[:comments_attributes][0][:_destroy]).to eq("1")
    end

    it "still strips the invalid declared value" do
      expect(result[:comments_attributes][0].key?(:status)).to be false
    end
  end

  describe "missing nested key" do
    let(:params) { ActionController::Parameters.new(title: "T") }

    it "is a no-op" do
      expect(result[:title]).to eq("T")
    end
  end

  describe "with :raise" do
    let(:invalid) { :raise }
    let(:params) do
      ActionController::Parameters.new(comments_attributes: [{ status: "spam" }])
    end

    it "raises UnexpectedValue for the offending nested value" do
      expect { result }.to raise_error(
        an_instance_of(Pundit::ExpectedAttributeValues::UnexpectedValue)
          .and(have_attributes(attribute: :status, value: "spam"))
      )
    end
  end
end
