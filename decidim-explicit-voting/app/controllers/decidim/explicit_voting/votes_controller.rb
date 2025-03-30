# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class VotesController < Decidim::ExplicitVoting::ApplicationController
      include Decidim::FormFactory

      def create
        enforce_permission_to :vote, :voting, voting: voting

        @form = form(VoteForm).from_params(
          params.merge(
            voting: voting,
            user: current_user
          )
        )

        CreateVote.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("votes.create.success", scope: "decidim.explicit_voting")
            redirect_to voting_path(voting)
          end

          on(:invalid) do
            flash[:alert] = I18n.t("votes.create.error", scope: "decidim.explicit_voting")
            redirect_to voting_path(voting)
          end
        end
      end

      def destroy
        @vote = Vote.find_by(voting: voting, user: current_user)
        
        if @vote&.destroy
          flash[:notice] = t(".success")
        else
          flash[:alert] = t(".error")
        end

        redirect_back(fallback_location: root_path)
      end

      private

      def voting
        @voting ||= Voting.find(params[:voting_id])
      end

      def vote_params
        params.require(:vote).permit(:vote_type)
      end
    end
  end
end 