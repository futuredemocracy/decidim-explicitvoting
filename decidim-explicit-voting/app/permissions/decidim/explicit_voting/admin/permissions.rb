# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          if permission_action.subject == :participatory_space && permission_action.action == :read
            allow! if user_is_admin? || user_is_space_admin?
            return permission_action
          end

          if permission_action.subject == :component && [:manage, :update].include?(permission_action.action)
            allow! if user_is_admin? || user_is_space_admin?
            return permission_action
          end

          if permission_action.subject == :voting
            case permission_action.action
            when :create, :read, :update, :destroy, :manage
              allow! if user_is_admin? || user_is_space_admin?
            end
            return permission_action
          end

          permission_action
        end

        private

        def user_is_admin?
          user&.admin?
        end

        def user_is_space_admin?
          current_component = component
          return false unless current_component&.participatory_space
          user.role?("admin").for?(current_component.participatory_space)
        end

        def component
          context.fetch(:current_component, nil) || context.fetch(:component, nil)
        end
      end
    end
  end
end
