# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # Delegate the admin permission checks to the admin permissions class
        return Decidim::ExplicitVoting::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        case permission_action.subject
        when :voting
          case permission_action.action
          when :read
            allow!
          when :vote
            can_vote?
          end
        end

        permission_action
      end

      private

      def can_vote?
        return disallow! unless user
        return disallow! unless voting.active?
        return disallow! if user_has_voted?

        allow!
      end

      def voting
        @voting ||= context.fetch(:voting, nil)
      end

      def user_has_voted?
        return false unless voting && user

        Decidim::ExplicitVoting::Vote.exists?(voting: voting, user: user)
      end
    end
  end
end 