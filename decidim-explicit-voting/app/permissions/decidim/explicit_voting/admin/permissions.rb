# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          return permission_action if permission_action.subject != :voting

          case permission_action.action
          when :create, :read, :update, :destroy, :manage
            toggle_allow(user.admin? || participatory_space_admin?)
          end

          permission_action
        end

        private

        def participatory_space_admin?
          return false unless participatory_space

          participatory_space.admins.include?(user)
        end
      end
    end
  end
end 