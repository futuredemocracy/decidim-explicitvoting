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

          transaction do
            create_voting
            create_default_options
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :voting

        def create_voting
          @voting = Decidim::ExplicitVoting::Voting.create!(
            component: form.current_component,
            title: form.title,
            description: form.description,
            start_date: form.start_date,
            end_date: form.end_date,
            secret: form.secret
          )
        end

        def create_default_options
          ["ZA", "PRZECIW", "WSTRZYMUJĘ SIĘ"].each_with_index do |name, index|
            Decidim::ExplicitVoting::VotingOption.create!(
              voting: voting,
              name: name,
              position: index
            )
          end
        end
      end
    end
  end
end 