# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    module Admin
      class VotingsController < Decidim::ExplicitVoting::Admin::ApplicationController
        helper_method :votings, :voting

        def index
          enforce_permission_to :read, :voting
        end

        def new
          enforce_permission_to :create, :voting
          @form = form(VotingForm).instance
        end

        def create
          enforce_permission_to :create, :voting
          @form = form(VotingForm).from_params(params)

          CreateVoting.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("votings.create.success", scope: "decidim.explicit_voting.admin")
              redirect_to votings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("votings.create.invalid", scope: "decidim.explicit_voting.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :voting, voting: voting
          @form = form(VotingForm).from_model(voting)
        end

        def update
          enforce_permission_to :update, :voting, voting: voting
          @form = form(VotingForm).from_params(params)

          UpdateVoting.call(@form, voting) do
            on(:ok) do
              flash[:notice] = I18n.t("votings.update.success", scope: "decidim.explicit_voting.admin")
              redirect_to votings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("votings.update.invalid", scope: "decidim.explicit_voting.admin")
              render :edit
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :voting, voting: voting

          DestroyVoting.call(voting, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("votings.destroy.success", scope: "decidim.explicit_voting.admin")
              redirect_to votings_path
            end
          end
        end

        def results
          enforce_permission_to :read, :voting, voting: voting
          @voting_options = voting.options.includes(:votes)
        end

        def protocol
          enforce_permission_to :read, :voting, voting: voting
          send_data generate_protocol(voting),
                  filename: "voting_protocol_#{voting.id}.csv",
                  type: "text/csv"
        end

        private

        def votings
          @votings ||= Voting.where(component: current_component)
        end

        def voting
          @voting ||= votings.find(params[:id])
        end

        def generate_protocol(voting)
          return unless voting.finished?

          CSV.generate do |csv|
            csv << ["User", "Vote"] unless voting.secret?
            csv << ["Total votes", voting.votes.count]
            
            voting.options.each do |option|
              csv << [option.name, option.votes.count]
            end

            unless voting.secret?
              voting.votes.includes(:user, :voting_option).each do |vote|
                csv << [vote.user.name, vote.voting_option.name]
              end
            end
          end
        end
      end
    end
  end
end 