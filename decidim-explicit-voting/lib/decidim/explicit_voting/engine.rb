# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    # This is the engine that runs on the public interface of explicit_voting.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ExplicitVoting

      routes do
        resources :votings, only: [:index, :show] do
          resources :votes, only: [:create, :destroy]
          resource :protocol, only: [:show]
        end
        root to: "votings#index"
      end

      initializer "decidim_explicit_voting.icons" do
        Decidim.icons.register(name: "pencil", icon: "pencil-alt", category: "system", description: "Edit icon", engine: :admin)
        Decidim.icons.register(name: "eye", icon: "eye", category: "system", description: "View icon", engine: :admin)
        Decidim.icons.register(name: "trash", icon: "trash", category: "system", description: "Delete icon", engine: :admin)
        Decidim.icons.register(name: "check", icon: "check", category: "system", description: "Check icon", engine: :admin)
        Decidim.icons.register(name: "download", icon: "download", category: "system", description: "Download icon", engine: :admin)
        Decidim.icons.register(name: "clipboard-list", icon: "clipboard-list", category: "system", description: "Results icon", engine: :admin)
      end

      initializer "decidim_explicit_voting.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ExplicitVoting::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ExplicitVoting::Engine.root}/app/views") # for partials
      end

      initializer "decidim_explicit_voting.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::ExplicitVoting::Engine, at: "/", as: "decidim_explicit_voting"
        end
      end

      initializer "decidim_explicit_voting.add_settings" do
        Decidim.component_registry.find(:explicit_voting).settings(:global) do |settings|
          settings.attribute :announcement, type: :text, translated: true, editor: true
        end

        Decidim.component_registry.find(:explicit_voting).settings(:step) do |settings|
          settings.attribute :announcement, type: :text, translated: true, editor: true
        end
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