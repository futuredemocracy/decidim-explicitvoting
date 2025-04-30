# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class Voting < ApplicationRecord
      include Decidim::HasComponent
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::TranslatableResource

      translatable_fields :title, :description

      belongs_to :component, foreign_key: "decidim_component_id", class_name: "Decidim::Component"
      delegate :organization, to: :component

      has_many :options, class_name: "Decidim::ExplicitVoting::VotingOption", foreign_key: "voting_id", dependent: :destroy
      has_many :votes, class_name: "Decidim::ExplicitVoting::Vote", foreign_key: "voting_id", dependent: :destroy
      has_many :protocols, class_name: "Decidim::ExplicitVoting::Protocol", foreign_key: "voting_id", dependent: :destroy

      validates :end_date, presence: true
      validate :validate_title_presence
      validate :validate_description_presence

      def to_s
        translated_field(:title)
      end

      def get_translated_field(field_name)
        translated_field(field_name)
      end

      def active?
        start_date <= Time.current && Time.current <= end_date
      end

      def upcoming?
        Time.current < start_date
      end

      def finished?
        Time.current > end_date
      end

      def default_locale
        organization&.default_locale || "pl"
      end

      def votes_count
        options.sum { |opt| opt&.votes_count.to_i }
      end

      def result_translation_key
        votes_for = options[0]&.votes_count.to_i
        votes_against = options[1]&.votes_count.to_i
        votes_neutral = options[2]&.votes_count.to_i
        total = votes_for + votes_against + votes_neutral

        return :quorum_not_met if total < quorum
        return :no_votes if total.zero?
        return :only_neutral if votes_for.zero? && votes_against.zero? && votes_neutral.positive?
        return :tie if votes_for == votes_against
        return :passed if votes_for > votes_against

        :rejected
      end

      private

      def translated_field(field_name)
        field = send(field_name)

        hash = case field
               when Hash
                 field
               when String
                 parse_yaml_safe(field) || {}
               else
                 {}
               end

        locale = I18n.locale.to_s
        hash[locale] || hash["pl"] || hash["en"] || hash.values.first || ""
      end

      def parse_yaml_safe(string)
        return unless string.include?("=>")

        YAML.safe_load(
          string.gsub(/=>/, ":"), # Zamień Ruby Hash na YAML format
          permitted_classes: [Hash],
          aliases: true
        )
      rescue Psych::SyntaxError
        nil
      end

      def method_missing(method, *args, &block)
        if method.to_s =~ /^(title|description)_([a-z]{2})$/
          translated_field($1)[ $2 ] || ""
        else
          super
        end
      end

      def respond_to_missing?(method, include_private = false)
        method.to_s =~ /^(title|description)_([a-z]{2})$/ || super
      end

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
