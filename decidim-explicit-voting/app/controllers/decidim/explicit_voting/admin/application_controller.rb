# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    module Admin
      class ApplicationController < Decidim::Admin::Components::BaseController
        layout "decidim/admin/application"

        def permission_class_chain
          [
            Decidim::ExplicitVoting::Admin::Permissions,
            Decidim::Admin::Permissions
          ]
        end
      end
    end
  end
end 