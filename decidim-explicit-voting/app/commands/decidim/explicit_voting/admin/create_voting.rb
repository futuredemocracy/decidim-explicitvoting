# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    module Admin
      class CreateVoting < Decidim::Command
        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) if form.invalid?

          begin
            transaction do
              create_voting
              create_options
            end

            broadcast(:ok)
          rescue StandardError => e
            form.errors.add(:base, e.message)
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :voting

        def create_voting
          @voting = Decidim::ExplicitVoting::Voting.new(
            component: form.current_component,
            start_date: form.start_date,
            end_date: form.end_date,
            secret: form.secret,
            title: translations_for(:title),
            description: translations_for(:description)
          )

          unless voting.save(validate: false)
            raise ActiveRecord::RecordNotSaved, voting
          end
        end

        def create_options
          [form.option_for, form.option_against, form.option_neutral].each_with_index do |name, index|
            option = Decidim::ExplicitVoting::VotingOption.new(
              voting: voting,
              name: name,
              position: index
            )

            unless option.save(validate: false)
              raise ActiveRecord::RecordNotSaved, option
            end
          end
        end

        def translations_for(attribute)
          form.current_organization.available_locales.each_with_object({}) do |locale, translations|
            value = form.public_send("#{attribute}_#{locale}") if form.respond_to?("#{attribute}_#{locale}")
            translations[locale] = value if value.present?
          end
        end
      end
    end
  end
end
