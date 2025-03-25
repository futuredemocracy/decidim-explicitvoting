# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = File.expand_path(File.join("spec", "dummy"))

require "decidim/dev/test/base_spec_helper"

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.order = :random
  config.include FactoryBot::Syntax::Methods
end 