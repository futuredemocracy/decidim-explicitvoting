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
              create_default_options
            end

            broadcast(:ok)
          rescue StandardError => e
            Rails.logger.error("Error creating voting: #{e.message}")
            Rails.logger.error("Backtrace: #{e.backtrace.join("\n")}")
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
            secret: form.secret
          )
          
          # Debugowanie
          Rails.logger.debug("Preparing to create voting...")
          
          # Tworzenie struktur tłumaczeń dla każdego języka
          title_translations = {}
          description_translations = {}
          
          # Przejdź przez wszystkie dostępne języki
          form.current_organization.available_locales.each do |locale|
            title_attr = "title_#{locale}"
            desc_attr = "description_#{locale}"
            
            title_val = form.respond_to?(title_attr) ? form.send(title_attr) : nil
            desc_val = form.respond_to?(desc_attr) ? form.send(desc_attr) : nil
            
            title_translations[locale] = title_val if title_val.present?
            description_translations[locale] = desc_val if desc_val.present?
            
            Rails.logger.debug("Locale #{locale}: title='#{title_val}', desc='#{desc_val}'")
          end
          
          # Przypisz tłumaczenia do obiektu
          @voting.title = title_translations
          @voting.description = description_translations
          
          Rails.logger.debug("Voting before save: title=#{@voting.title.inspect}, description=#{@voting.description.inspect}")
          
          # Zapisz obiekt z pominięciem walidacji, jako że już zweryfikowaliśmy dane w formularzu
          unless @voting.save(validate: false)
            Rails.logger.error("Voting errors: #{@voting.errors.full_messages.join(", ")}")
            raise ActiveRecord::RecordNotSaved, @voting
          end
          
          Rails.logger.debug("Voting created with ID: #{@voting.id}")
        end

        def create_default_options
          ["ZA", "PRZECIW", "WSTRZYMUJĘ SIĘ"].each_with_index do |name, index|
            option = Decidim::ExplicitVoting::VotingOption.new(
              voting: voting,
              name: name,
              position: index
            )
            
            unless option.save(validate: false)
              Rails.logger.error("Option errors: #{option.errors.full_messages.join(", ")}")
              raise ActiveRecord::RecordNotSaved, option
            end
            
            Rails.logger.debug("Created option '#{name}' for voting #{@voting.id}")
          end
        end
      end
    end
  end
end 