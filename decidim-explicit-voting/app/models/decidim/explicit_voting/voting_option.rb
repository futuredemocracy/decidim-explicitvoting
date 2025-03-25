# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class VotingOption < ApplicationRecord
      self.table_name = "decidim_explicit_voting_options"

      belongs_to :voting, class_name: "Decidim::ExplicitVoting::Voting"

      has_many :votes,
               class_name: "Decidim::ExplicitVoting::Vote",
               foreign_key: "voting_option_id",
               dependent: :destroy

      validates :name, presence: true

      default_scope { order(position: :asc) }

      def votes_count
        return 0 if voting.secret? && !voting.finished?

        votes.count
      end
    end
  end
end 