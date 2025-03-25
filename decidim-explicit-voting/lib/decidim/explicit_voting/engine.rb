# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ExplicitVoting

      routes do
        resources :votings, only: [:index, :show] do
          resources :votes, only: [:create]
          resource :protocol, only: [:show]
        end
        root to: "votings#index"
      end

      initializer "decidim_explicit_voting.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ExplicitVoting::Engine.root}/app/cells")
      end

      initializer "decidim_explicit_voting.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_explicit_voting.authorization_transfer" do
        config.to_prepare do
          Decidim::AuthorizationTransfer.register(:explicit_voting_votes) do |transfer|
            transfer.move_records(Decidim::ExplicitVoting::Vote, :decidim_user_id)
          end
        end
      end
    end
  end
end 