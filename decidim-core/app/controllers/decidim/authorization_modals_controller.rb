# frozen_string_literal: true

module Decidim
  class AuthorizationModalsController < Decidim::ApplicationController
    helper_method :authorizations, :authorize_action_path
    layout false

    def show
      store_onboarding_cookie_data!(current_user)
    end

    def authorize_action_path(handler_name)
      authorizations.status_for(handler_name).current_path(redirect_url:)
    end

    private

    def resource
      @resource ||= if params[:resource_name] && params[:resource_id]
                      manifest = Decidim.find_resource_manifest(params[:resource_name])
                      manifest&.resource_scope(current_component)&.find_by(id: params[:resource_id])
                    end
    end

    def current_component
      @current_component ||= Decidim::Component.where(participatory_space: current_organization.participatory_spaces).find(params[:component_id])
    end

    def authorization_action
      @authorization_action ||= params[:authorization_action]
    end

    def authorizations
      @authorizations ||= action_authorized_to(authorization_action, resource:)
    end

    def redirect_url
      pending_onboarding_action?(current_user) ? decidim_verifications.onboarding_pending_authorizations_path : URI(request.referer).path
    end
  end
end
