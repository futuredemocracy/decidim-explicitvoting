# frozen_string_literal: true

Decidim.register_component(:explicit_voting) do |component|
  component.engine = Decidim::ExplicitVoting::Engine
  component.admin_engine = Decidim::ExplicitVoting::AdminEngine
  component.icon = "decidim/explicit_voting/icon.svg"

  component.permissions_class_name = "Decidim::ExplicitVoting::Permissions"

  # These actions permissions can be configured in the admin panel
  component.actions = %w(create read update destroy)

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_stat :votings_count do |components, start_at, end_at|
    votings = Decidim::ExplicitVoting::Voting.where(component: components)
    votings = votings.where("created_at >= ?", start_at) if start_at.present?
    votings = votings.where("created_at <= ?", end_at) if end_at.present?
    votings.count
  end

  component.register_stat :votes_count do |components, start_at, end_at|
    votings = Decidim::ExplicitVoting::Voting.where(component: components)
    votes = Decidim::ExplicitVoting::Vote.where(voting: votings)
    votes = votes.where("created_at >= ?", start_at) if start_at.present?
    votes = votes.where("created_at <= ?", end_at) if end_at.present?
    votes.count
  end

  component.seeds do |participatory_space|
    admin_user = Decidim::User.find_by(
      organization: participatory_space.organization,
      email: "admin@example.org"
    )

    params = {
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :explicit_voting).i18n_name,
      manifest_name: :explicit_voting,
      published_at: Time.current,
      participatory_space: participatory_space,
      permissions: {
        "create" => {
          "authorization_handlers" => {
            "default" => {
              "options" => {
                "permissions" => {
                  "create" => true,
                  "read" => true,
                  "update" => true,
                  "destroy" => true
                }
              }
            }
          }
        }
      }
    }

    component = Decidim.traceability.perform_action!(
      "publish",
      Decidim::Component,
      admin_user,
      visibility: "all"
    ) do
      Decidim::Component.create!(params)
    end

    # Create example voting
    voting = Decidim::ExplicitVoting::Voting.create!(
      component: component,
      title: Decidim::Faker::Localized.sentence(word_count: 2),
      description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(sentence_count: 3)
      end,
      start_date: 1.day.from_now,
      end_date: 1.week.from_now,
      secret: [true, false].sample
    )

    # Create default options
    ["ZA", "PRZECIW", "WSTRZYMUJĘ SIĘ"].each_with_index do |name, index|
      Decidim::ExplicitVoting::VotingOption.create!(
        voting: voting,
        name: name,
        position: index
      )
    end
  end
end 