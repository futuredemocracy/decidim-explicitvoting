# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class VotingOption < ApplicationRecord
      belongs_to :voting, class_name: "Decidim::ExplicitVoting::Voting"

      has_many :votes,
               class_name: "Decidim::ExplicitVoting::Vote",
               foreign_key: "voting_option_id",
               dependent: :destroy

      validates :title, presence: true
      validates :description, presence: true

      default_scope { order(position: :asc) }

      def votes_count
        votes.count
      end
    end
  end
end 