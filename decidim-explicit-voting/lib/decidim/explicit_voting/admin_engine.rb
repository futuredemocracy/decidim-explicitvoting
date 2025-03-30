# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class AdminEngine < ::Rails::Engine
      isolate_namespace ::Decidim::ExplicitVoting::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :votings do
          resources :voting_options, except: [:show] do
            collection do
              post :update_positions
            end
          end
          member do
            get :results
            get :protocol
          end
        end

        root to: "votings#index"
      end

      initializer "decidim_explicit_voting_admin.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::ExplicitVoting::AdminEngine, at: "/admin/explicit_voting", as: "decidim_admin_explicit_voting"
        end
      end

      initializer "decidim_explicit_voting_admin.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ExplicitVoting::Engine.root}/app/cells")
      end

      initializer "decidim_explicit_voting_admin.register_icons" do
        Decidim.icons.register(name: "chart-bar", icon: "chart-bar", category: "system", description: "Chart icon", engine: :core)
      end

      def load_seed
        nil
      end
    end
  end
end 