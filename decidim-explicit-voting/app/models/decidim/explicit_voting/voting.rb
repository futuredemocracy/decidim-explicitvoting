# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class Voting < ApplicationRecord
      self.table_name = "decidim_explicit_votings"

      include Decidim::HasComponent
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::TranslatableResource

      translatable_fields :title, :description

      belongs_to :component, foreign_key: "decidim_component_id", class_name: "Decidim::Component"

      delegate :organization, to: :component

      has_many :options,
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

      #validates :title, translatable_presence: true
      #validates :description, translatable_presence: true
      validates :end_date, presence: true

      def active?
        return false unless start_date.present?
        
        start_date <= Time.current && Time.current <= end_date
      end

      def upcoming?
        return false unless start_date.present?
        
        Time.current < start_date
      end

      def finished?
        Time.current > end_date
      end

      def current_organization
        organization
      end
    end
  end
end 