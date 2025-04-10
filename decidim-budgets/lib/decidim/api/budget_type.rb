# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Core::TraceableInterface

      description "A budget"

      field :description, Decidim::Core::TranslatedFieldType, "The description for this budget", null: false
      field :id, GraphQL::Types::ID, "The internal ID of this budget", null: false
      field :projects, [Decidim::Budgets::ProjectType, { null: true }], "The projects for this budget", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this budget", null: false
      field :total_budget, GraphQL::Types::Int, "The total budget", null: false, camelize: false

      def self.authorized?(object, context)
        super && object.visible?
      rescue Decidim::PermissionAction::PermissionNotSetError
        false
      end
    end
  end
end
