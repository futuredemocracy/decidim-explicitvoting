# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class VoteForm < Decidim::Form
      mimic :vote

      attribute :voting_option_id, Integer
      attribute :voting_id, Integer
      attribute :user, Object

      validates :voting_option_id, presence: true
      validates :voting, presence: true
      validates :user, presence: true

      validate :user_can_vote
      validate :voting_is_active
      validate :option_belongs_to_voting

      def voting
        @voting ||= Decidim::ExplicitVoting::Voting.find_by(id: voting_id)
      end

      def voting_option
        @voting_option ||= Decidim::ExplicitVoting::VotingOption.find_by(id: voting_option_id)
      end

      private

      def user_can_vote
        return unless voting && user
        return unless Decidim::ExplicitVoting::Vote.exists?(voting: voting, user: user)

        errors.add(:voting, :already_voted)
      end

      def voting_is_active
        return unless voting
        return if voting.active?

        errors.add(:voting, :inactive)
      end

      def option_belongs_to_voting
        return unless voting && voting_option
        return if voting_option.voting_id == voting.id

        errors.add(:voting_option, :invalid)
      end
    end
  end
end 