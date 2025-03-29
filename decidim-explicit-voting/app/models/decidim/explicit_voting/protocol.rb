# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class Protocol < ApplicationRecord
      self.table_name = "decidim_explicit_voting_protocols"
      
      belongs_to :voting, class_name: "Decidim::ExplicitVoting::Voting"

      validates :voting, presence: true
      validates :file_path, presence: true, if: :generated_at?
      validates :generated_at, presence: true, if: :file_path?

      def generate
        return false unless voting.finished?
        return false if generated_at.present?

        # TODO: Implement protocol generation logic
        self.generated_at = Time.current
        save
      end
    end
  end
end 