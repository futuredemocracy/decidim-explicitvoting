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

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :end_date, presence: true
        validate :end_date_after_start_date

        def map_model(model)
          self.title = model.title
          self.description = model.description
          self.start_date = model.start_date
          self.end_date = model.end_date
          self.secret = model.secret
        end
        
        # Metoda pomocnicza do pobierania wszystkich tłumaczeń tytułu
        def title_hash
          title_as_hash = {}
          
          current_organization.available_locales.each do |locale|
            title_attr = "title_#{locale}"
            title_as_hash[locale] = send(title_attr) if send(title_attr).present?
          end
          
          title_as_hash
        end
        
        # Metoda pomocnicza do pobierania wszystkich tłumaczeń opisu
        def description_hash
          description_as_hash = {}
          
          current_organization.available_locales.each do |locale|
            desc_attr = "description_#{locale}"
            description_as_hash[locale] = send(desc_attr) if send(desc_attr).present?
          end
          
          description_as_hash
        end

        private

        def end_date_after_start_date
          return unless start_date.present? && end_date.present?
          return if end_date > start_date

          errors.add(:end_date, I18n.t("voting_form.errors.end_date_after_start_date", scope: "decidim.explicit_voting.admin"))
        end
      end
    end
  end
end 