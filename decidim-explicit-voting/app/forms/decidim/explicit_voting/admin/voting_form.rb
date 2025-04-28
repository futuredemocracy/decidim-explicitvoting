# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    module Admin
      class VotingForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String

        attribute :start_date, Decidim::Attributes::TimeWithZone
        attribute :end_date, Decidim::Attributes::TimeWithZone
        attribute :secret, Boolean
        attribute :option_for, String, default: "ZA"
        attribute :option_against, String, default: "PRZECIW"
        attribute :option_neutral, String, default: "WSTRZYMUJĘ SIĘ"
        attribute :quorum, default: 0

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :start_date, presence: true
        validates :end_date, presence: true
        validate :end_date_after_start_date
        validate :options_unique
        validates :quorum, numericality: { greater_than_or_equal_to: 0, only_integer: true }

        private

        def end_date_after_start_date
          return unless start_date.present? && end_date.present?
          return if end_date > start_date

          errors.add(:end_date, I18n.t("voting_form.errors.end_date_after_start_date", scope: "decidim.explicit_voting.admin"))
        end

        def options_unique
          opts = [option_for, option_against, option_neutral]
          if opts.uniq.size != opts.size
            errors.add(:base, I18n.t("voting_form.errors.duplicate_options", scope: "decidim.explicit_voting.admin"))
          end
        end
      end
    end
  end
end
