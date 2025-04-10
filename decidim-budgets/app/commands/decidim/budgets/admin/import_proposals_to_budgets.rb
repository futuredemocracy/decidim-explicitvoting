# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # A command with all the business logic when an admin imports proposals from
      # one component to projects of a budget.
      class ImportProposalsToBudgets < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless @form.valid?

          broadcast(:ok, create_projects_from_accepted_proposals)
        end

        private

        attr_reader :form

        def create_projects_from_accepted_proposals
          transaction do
            proposals.map do |original_proposal|
              next if proposal_already_copied?(original_proposal)

              new_project = create_project_from_proposal!(original_proposal)

              new_project.link_resources([original_proposal], "included_proposals")
            end.compact
          end
        end

        def create_project_from_proposal!(original_proposal)
          params = {
            budget: form.budget,
            title: original_proposal.title,
            description: original_proposal.body,
            budget_amount: budget_for(original_proposal),
            taxonomies: original_proposal.taxonomies,
            address: original_proposal.address,
            latitude: original_proposal.latitude,
            longitude: original_proposal.longitude
          }

          @project = Decidim.traceability.create!(
            Project,
            form.current_user,
            params,
            visibility: "all"
          )
        end

        def budget_for(original_proposal)
          return form.default_budget if original_proposal.cost.blank?

          original_proposal.cost
        end

        def proposals
          Decidim::Proposals::Proposal.where(component: origin_component).published.not_hidden.not_withdrawn.accepted.order(:published_at)
        end

        def origin_component
          form.origin_component
        end

        def proposal_already_copied?(original_proposal)
          # Note: we are including also projects from unpublished components
          # because otherwise duplicates could be created until the component is
          # published.
          original_proposal.linked_resources(:projects, "included_proposals", component_published: false).any? do |project|
            component_budgets.exists?(project.decidim_budgets_budget_id)
          end
        end

        def component_budgets
          @component_budgets ||= Decidim::Budgets::Budget.where(component: form.budget.component)
        end
      end
    end
  end
end
