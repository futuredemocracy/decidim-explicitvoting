# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class VotingsController < Decidim::ExplicitVoting::ApplicationController
      include Decidim::ComponentPathHelper
      helper_method :votings, :voting, :user_vote

      def index
        enforce_permission_to :read, :voting
      end

      def show
        enforce_permission_to :read, :voting, voting: voting
        @voting_options = voting.options.includes(:votes)
        @form = form(VoteForm).instance
      end

      private

      def votings
        @votings ||= Voting.where(component: current_component).order(end_date: :desc)
      end

      def voting
        @voting ||= votings.find(params[:id])
      end

      def user_vote
        return nil unless current_user
        @user_vote ||= Vote.find_by(voting: voting, user: current_user)
      end
    end
  end
end 