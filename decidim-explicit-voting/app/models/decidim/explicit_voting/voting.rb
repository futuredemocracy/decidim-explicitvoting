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

      validates :end_date, presence: true
      validate :validate_title_presence
      validate :validate_description_presence
      
      def method_missing(method, *args, &block)
        if method.to_s =~ /^(title|description)_([a-z]{2})$/
          field_name = $1
          locale = $2
          
          translations = self.send(field_name.to_sym)
          return translations[locale] if translations
          
          return ""
        end
        
        super
      end
      
      def respond_to_missing?(method, include_private = false)
        method.to_s =~ /^(title|description)_([a-z]{2})$/ || super
      end

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
      
      def default_locale
        organization&.default_locale || "en"
      end
      
      private
      
      def validate_title_presence
        if title.blank? || title[default_locale].blank?
          errors.add(:title, :invalid)
        end
      end
      
      def validate_description_presence
        if description.blank? || description[default_locale].blank?
          errors.add(:description, :invalid)
        end
      end
    end
  end
end 