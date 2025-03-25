# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class CreateVote < Decidim::Command
      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        create_vote

        broadcast(:ok)
      end

      private

      attr_reader :form, :vote

      def create_vote
        @vote = Decidim::ExplicitVoting::Vote.create!(
          voting: form.voting,
          voting_option: form.voting_option,
          user: form.current_user
        )
      end
    end
  end
end 