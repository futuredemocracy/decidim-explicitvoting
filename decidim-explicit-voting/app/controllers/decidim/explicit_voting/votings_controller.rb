# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class VotingsController < Decidim::ExplicitVoting::ApplicationController
      include Decidim::ComponentPathHelper
      include Decidim::FormFactory
      helper_method :votings, :voting, :user_vote

      def index
        enforce_permission_to :read, :voting, participatory_space: current_participatory_space
      end

      def show
        enforce_permission_to :read, :voting, participatory_space: current_participatory_space
        @voting_options = voting.options.includes(:votes)
        @form = form(Decidim::ExplicitVoting::VoteForm).instance
      end

      def protocol
        enforce_permission_to :read, :voting, participatory_space: current_participatory_space

        respond_to do |format|
          format.pdf do
            pdf_generator = Decidim::ExplicitVoting::GenerateProtocolPdf.new(voting)
            pdf = pdf_generator.call
            send_data pdf.render,
                      filename: "protokol_glosowania_#{voting.id}.pdf",
                      type: "application/pdf",
                      disposition: "attachment"
          end

          format.html do
            redirect_to votings_path, alert: I18n.t("votings.protocol.no_html_format", scope: "decidim.explicit_voting.admin")
          end
        end
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
