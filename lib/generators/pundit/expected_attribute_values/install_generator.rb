# frozen_string_literal: true

require "rails/generators/base"

module Pundit
  module ExpectedAttributeValues
    module Generators
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)

        desc "Install Pundit::ExpectedAttributeValues in ApplicationPolicy and ApplicationController"

        class_option :test_framework, type: :string, default: nil,
                                      desc: "Test framework (rspec or minitest)"

        def add_policy_concern
          inject_into_class policy_path, "ApplicationPolicy", <<-RUBY

    include Pundit::ExpectedAttributeValues::Policy
          RUBY
        end

        def add_controller_concern
          inject_into_class controller_path, "ApplicationController", <<-RUBY

    include Pundit::ExpectedAttributeValues::Authorization
          RUBY
        end

        def add_test_helper_snippet
          template "test_helper.#{detected_test_framework}.rb", test_helper_destination
        end

        private

        def policy_path
          "app/policies/application_policy.rb"
        end

        def controller_path
          "app/controllers/application_controller.rb"
        end

        def detected_test_framework
          return options[:test_framework] if options[:test_framework]

          File.directory?("spec") ? "rspec" : "minitest"
        end

        def test_helper_destination
          if detected_test_framework == "rspec"
            "spec/support/pundit-expected-attribute-values.rb"
          else
            "test/support/pundit-expected-attribute-values.rb"
          end
        end
      end
    end
  end
end
