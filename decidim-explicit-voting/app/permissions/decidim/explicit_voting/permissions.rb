# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # Delegate the admin permission checks to the admin permissions class
        return Decidim::ExplicitVoting::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        if permission_action.subject == :participatory_space && permission_action.action == :read
          allow! if can_read?
          return permission_action
        end

        if permission_action.subject == :component && permission_action.action == :read
          allow! if can_read?
          return permission_action
        end

        case permission_action.subject
        when :voting
          case permission_action.action
          when :read
            can_read?
          when :vote
            can_vote?
          end
        end

        permission_action
      end

      private

      def can_read?
        return disallow! unless user
        return disallow! unless user_in_private_users_list? || participatory_space_admin? || organization_admin?

        allow!
      end

      def can_vote?
        return disallow! unless user
        return disallow! unless voting.active?
        return disallow! if user_has_voted?
        return disallow! unless user_in_private_users_list? || participatory_space_admin?

        allow!
      end

      def user_in_private_users_list?
        participatory_space.participatory_space_private_users.exists?(decidim_user_id: user.id)
      end

      def participatory_space_admin?
        participatory_space.user_roles.exists?(decidim_user_id: user.id)
      end

      def organization_admin?
        participatory_space.organization.admins.exists?(id: user.id)
      end

      def voting
        @voting ||= context.fetch(:voting, nil)
      end

      def participatory_space
        @participatory_space ||= context.fetch(:participatory_space, nil) || context.fetch(:current_participatory_space, nil) || context.fetch(:current_component,nil)&.participatory_space
      end

      def user_has_voted?
        return false unless voting && user

        Decidim::ExplicitVoting::Vote.exists?(voting: voting, user: user)
      end
    end
  end
end
