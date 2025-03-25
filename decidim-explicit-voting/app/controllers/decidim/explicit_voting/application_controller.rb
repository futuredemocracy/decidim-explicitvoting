# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    # This controller is the base controller for all controllers in the ExplicitVoting engine.
    class ApplicationController < Decidim::Components::BaseController
      helper Decidim::ApplicationHelper
      helper Decidim::TranslationsHelper
      helper Decidim::MetaTagsHelper
      
      helper_method :current_organization
    end
  end
end 