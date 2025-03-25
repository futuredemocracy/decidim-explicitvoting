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
      
      def to_s
        # Próbujemy obsłużyć zarówno przypadek gdy title jest hashem,
        # jak i gdy jest stringiem reprezentującym hash
        if title.is_a?(Hash)
          hash = title
        elsif title.is_a?(String) && title.include?("=>")
          # Spróbuj zparsować string jako hash Rubiego
          begin
            hash = eval(title)
          rescue
            return title
          end
        else
          return title.to_s
        end
        
        locale = I18n.locale.to_s
        hash[locale] || hash["pl"] || hash["en"] || hash.values.first || ""
      end
      
      def get_translated_field(field_name)
        field = self.send(field_name.to_sym)
        
        if field.is_a?(Hash)
          hash = field
        elsif field.is_a?(String) && field.include?("=>")
          # Spróbuj zparsować string jako hash Rubiego
          begin
            hash = eval(field)
          rescue
            return field
          end
        else
          return field.to_s
        end
        
        locale = I18n.locale.to_s
        hash[locale] || hash["pl"] || hash["en"] || hash.values.first || ""
      end
      
      def method_missing(method, *args, &block)
        if method.to_s =~ /^(title|description)_([a-z]{2})$/
          field_name = $1
          locale = $2
          
          field = self.send(field_name.to_sym)
          
          if field.is_a?(Hash)
            return field[locale] || ""
          elsif field.is_a?(String) && field.include?("=>")
            begin
              hash = eval(field)
              return hash[locale] || ""
            rescue
              return ""
            end
          end
          
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
        if title.blank? || (title.is_a?(Hash) && title[default_locale].blank?)
          errors.add(:title, :invalid)
        end
      end
      
      def validate_description_presence
        if description.blank? || (description.is_a?(Hash) && description[default_locale].blank?)
          errors.add(:description, :invalid)
        end
      end
    end
  end
end 