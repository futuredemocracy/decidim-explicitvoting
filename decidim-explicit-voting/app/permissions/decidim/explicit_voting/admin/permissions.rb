# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          if permission_action.subject == :participatory_space && permission_action.action == :read
            allow! if admin?
            return permission_action
          end

          if permission_action.subject == :component && [:read, :manage, :update].include?(permission_action.action)
            allow! if admin?
            return permission_action
          end

          if permission_action.subject == :voting
            case permission_action.action
            when :create, :read
              allow! if admin?
            when :destroy
              allow! if admin? && voting.upcoming?
            end
            return permission_action
          end

          permission_action
        end

        private

        def admin?
          user_is_admin? || user_is_space_admin?
        end

        def user_is_admin?
          user&.admin?
        end

        def user_is_space_admin?
          component.participatory_space.user_roles.exists?(decidim_user_id: user.id, role: "admin")
        end

        def component
          context.fetch(:current_component, nil) || context.fetch(:component, nil)
        end

        def voting
          @voting ||= context.fetch(:voting, nil)
        end
      end
    end
  end
end
