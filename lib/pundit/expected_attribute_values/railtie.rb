# frozen_string_literal: true

module Pundit
  module ExpectedAttributeValues
    class Railtie < Rails::Railtie
      initializer "pundit-expected-attribute-values.configure" do
        # Host apps may call Pundit::ExpectedAttributeValues.configure in an initializer.
      end
    end
  end
end
