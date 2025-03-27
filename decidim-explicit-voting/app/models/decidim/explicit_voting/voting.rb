# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class Voting < ApplicationRecord
      include Decidim::HasComponent
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :component, class_name: "Decidim::Component"

      has_many :voting_options,
               class_name: "Decidim::ExplicitVoting::VotingOption",
               foreign_key: "voting_id",
               dependent: :destroy

      has_many :votes,
               class_name: "Decidim::ExplicitVoting::Vote",
               foreign_key: "voting_id",
               dependent: :destroy

      has_many :protocols,
               class_name: "Decidim::ExplicitVoting::Protocol",
               foreign_key: "voting_id",
               dependent: :destroy

      validates :title, presence: true
      validates :description, presence: true
      validates :start_date, presence: true
      validates :end_date, presence: true

      scope :active, -> { where("start_date <= ? AND end_date >= ?", Time.current, Time.current) }

      def active?
        start_date <= Time.current && end_date >= Time.current
      end

      def upcoming?
        return false unless start_date.present?
        
        Time.current < start_date
      end

      def finished?
        Time.current > end_date
      end
    end
  end
end 