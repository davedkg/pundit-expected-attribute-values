require "rails_helper"

# Policy-only specs demonstrating the gem's RSpec matchers
# (permit_expected_value / permit_expected_values). Models are unsaved, so no
# database rows are needed; allowed values change with the user's role.
RSpec.describe PostPolicy do
  subject(:policy) { described_class.new(user, Post.new) }

  describe "status (scalar value)" do
    context "as a member" do
      let(:user) { User.new(role: "member") }

      it { is_expected.to permit_expected_value(:status, "draft") }
      it { is_expected.not_to permit_expected_value(:status, "published") }
      it { is_expected.to permit_expected_values(:status).matching(%w[draft]) }
    end

    context "as an editor" do
      let(:user) { User.new(role: "editor") }

      it { is_expected.to permit_expected_values(:status).matching(%w[draft published]) }
    end

    context "as an admin" do
      let(:user) { User.new(role: "admin") }

      it { is_expected.to permit_expected_value(:status, "archived") }
    end
  end

  describe "tags (collection value)" do
    context "as a member" do
      let(:user) { User.new(role: "member") }

      it { is_expected.to permit_expected_value(:tags, "ruby") }
      it { is_expected.not_to permit_expected_value(:tags, "security") }
    end

    context "as an editor" do
      let(:user) { User.new(role: "editor") }

      it { is_expected.to permit_expected_value(:tags, "security") }
    end
  end
end
