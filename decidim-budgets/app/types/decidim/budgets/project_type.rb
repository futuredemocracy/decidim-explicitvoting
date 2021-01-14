# frozen_string_literal: true

module Decidim
  module Budgets
    ProjectType = GraphQL::ObjectType.define do
      Decidim::Budgets::Project.include Decidim::Core::GraphQLApiTransition
      interfaces [
        -> { Decidim::Core::ScopableInterface },
        -> { Decidim::Core::AttachableInterface },
        -> { Decidim::Comments::CommentableInterface },
        -> { Decidim::Core::CategorizableInterface }
      ]

      name "Project"
      description "A project"

      field :id, !types.ID, "The internal ID for this project"
      field :title, Decidim::Core::TranslatedFieldType, "The title for this project"
      field :description, Decidim::Core::TranslatedFieldType, "The description for this project"
      field :budget_amount, types.Int, "The budget amount for this project"
      field :selected, types.Boolean, "Whether this proposal is selected or not", property: :selected?
      field :createdAt, Decidim::Core::DateTimeType, "When this project was created", property: :created_at
      field :updatedAt, Decidim::Core::DateTimeType, "When this project was updated", property: :updated_at
      field :reference, types.String, "The reference for this project"

      field :userAllowedToComment, !types.Boolean, "Check if the current user can comment" do
        resolve lambda { |obj, _args, ctx|
          obj.commentable? && obj.user_allowed_to_comment?(ctx[:current_user])
        }
      end
    end
  end
end
