# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    module Admin
      # Controller for managing Votings in the admin panel.
      class VotingsController < Decidim::ExplicitVoting::Admin::ApplicationController
        # Przywracamy :votings i używamy :resource dla pojedynczego rekordu
        helper_method :votings, :resource

        def index
          enforce_permission_to :read, :voting
          # Ustawiamy zmienną instancyjną @votings dla widoku
          @votings = collection.order(created_at: :desc)
        end

        def show
          enforce_permission_to :read, :voting, voting: resource
          # Używamy metody 'resource' zdefiniowanej niżej
          # @voting = resource # Niepotrzebne, jeśli widok używa 'resource'
        end

        def new
          enforce_permission_to :create, :voting
          @form = form(VotingForm).instance
        end

        def create
          enforce_permission_to :create, :voting
          @form = form(VotingForm).from_params(params)

          if @form.valid?
            @voting = Decidim::ExplicitVoting::Voting.new(component: current_component)

            attributes_from_form = @form.attributes.slice(
              "title",
              "description",
              "start_date",
              "end_date",
              "secret"
            )
            @voting.assign_attributes(attributes_from_form)

            if @voting.save!
              flash[:notice] = I18n.t("votings.create.success", scope: "decidim.explicit_voting.admin")
              redirect_to votings_path
            end
          else
            flash.now[:alert] = I18n.t("votings.create.error", scope: "decidim.explicit_voting.admin")
            render :new, status: :unprocessable_entity
          end
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error("Admin Votings Create Validation failed: #{e.message}")
          flash.now[:alert] = I18n.t(
            "votings.create.error",
            scope: "decidim.explicit_voting.admin",
            error: e.record.errors.full_messages.join(", ")
          )
          render :new, status: :unprocessable_entity
        end

        def edit
          enforce_permission_to :update, :voting, voting: resource
          # Używamy metody 'resource' i wypełniamy formularz
          @form = form(VotingForm).from_model(resource)
        end

        def update
          enforce_permission_to :update, :voting, voting: resource
          @voting = resource # Potrzebujemy obiektu do aktualizacji

          @form = form(VotingForm).from_params(params)

          if @form.valid?
            attributes_from_form = @form.attributes.slice(
              "title",
              "description",
              "start_date",
              "end_date",
              "secret"
            )

            if @voting.update!(attributes_from_form)
              flash[:notice] = I18n.t("votings.update.success", scope: "decidim.explicit_voting.admin")
              redirect_to votings_path
            end
          else
            flash.now[:alert] = I18n.t("votings.update.error", scope: "decidim.explicit_voting.admin")
            render :edit, status: :unprocessable_entity
          end
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error("Admin Votings Update Validation failed: #{e.message}")
          flash.now[:alert] = I18n.t(
            "votings.update.error",
            scope: "decidim.explicit_voting.admin",
            error: e.record.errors.full_messages.join(", ")
          )
          render :edit, status: :unprocessable_entity
        end

        def destroy
          enforce_permission_to :destroy, :voting, voting: resource
          @voting = resource # Potrzebujemy obiektu do usunięcia

          if @voting.destroy
            flash[:notice] = I18n.t("votings.destroy.success", scope: "decidim.explicit_voting.admin")
          else
            flash[:alert] = I18n.t("votings.destroy.error", scope: "decidim.explicit_voting.admin", error: @voting.errors.full_messages.join(", "))
          end
          redirect_to votings_path, status: :see_other
        end

        def results
          enforce_permission_to :read, :voting, voting: resource
          # Używamy metody 'resource'
          # @voting = resource
          # Logika wyświetlania wyników
        end

        def protocol
          enforce_permission_to :read, :voting, voting: resource
          # Używamy metody 'resource'
          # @voting = resource
          # Logika wyświetlania protokołu
        end

        # --- POCZĄTEK PRZYWRÓCONEJ METODY VOTINGS ---
        # Metoda dostępna jako helper dla widoku `index.html.erb`
        def votings
          # Zwraca kolekcję przypisaną w akcji `index`
          # lub bezpośrednio wywołuje metodę `collection`, jeśli @votings nie zostało ustawione
          @votings ||= collection.order(created_at: :desc)
        end
        # --- KONIEC PRZYWRÓCONEJ METODY VOTINGS ---

        private

        # Zwraca kolekcję Voting należących do bieżącego komponentu
        def collection
          @collection ||= Decidim::ExplicitVoting::Voting.where(component: current_component)
        end

        # Zwraca pojedynczy zasób (Voting) na podstawie ID z parametrów
        # Dostępne jako helper_method :resource
        def resource
          @resource ||= collection.find(params[:id])
        end

      end
    end
  end
end