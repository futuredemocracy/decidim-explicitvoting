# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class Vote < ApplicationRecord
      self.table_name = "decidim_explicit_votes"
      
      belongs_to :voting, class_name: "Decidim::ExplicitVoting::Voting"
      belongs_to :voting_option, class_name: "Decidim::ExplicitVoting::VotingOption"
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

      validates :voting, presence: true
      validates :voting_option, presence: true
      validates :user, presence: true
      validates :voting_id, uniqueness: { scope: :decidim_user_id }

      validate :voting_is_active
      validate :voting_option_belongs_to_voting

      private

      def voting_is_active
        return if voting&.active?

        errors.add(:voting, :inactive)
      end

      def voting_option_belongs_to_voting
        return unless voting && voting_option
        return if voting_option.voting_id == voting.id

        errors.add(:voting_option, :invalid)
      end
    end
  end
end 