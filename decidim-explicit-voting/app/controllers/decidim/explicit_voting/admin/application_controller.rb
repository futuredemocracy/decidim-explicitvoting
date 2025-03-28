# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    module Admin
      class ApplicationController < Decidim::Admin::ApplicationController
        include Decidim::ParticipatorySpaceContext
        include Decidim::NeedsComponent

        layout "decidim/admin/application"

        def permissions_context
          super.merge(
            current_participatory_space: current_participatory_space
          )
        end

        def permission_class_chain
          [
            Decidim::ExplicitVoting::Admin::Permissions,
            Decidim::Admin::Permissions
          ]
        end

        private

        def current_participatory_space
          @current_participatory_space ||= current_component.participatory_space
        end
      end
    end
  end
end 