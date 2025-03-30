# frozen_string_literal: true

# Wstępne załadowanie biblioteki Prawn
begin
  require 'prawn'
  require 'prawn/font/ttf'
  require 'prawn/table'
rescue LoadError => e
  puts "Nie można załadować biblioteki Prawn lub jej zależności: #{e.message}"
end

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
          
          respond_to do |format|
            format.html
            format.pdf do
              pdf = generate_voting_list_pdf(@votings)
              send_data pdf.render,
                filename: "lista_glosowan_#{Time.current.strftime('%Y%m%d')}.pdf",
                type: "application/pdf",
                disposition: "attachment"
            end
          end
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

          CreateVoting.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("votings.create.success", scope: "decidim.explicit_voting.admin")
              redirect_to votings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("votings.create.error", scope: "decidim.explicit_voting.admin")
              render :new, status: :unprocessable_entity
            end
          end
        end

        def edit
          enforce_permission_to :update, :voting, voting: resource
          voting = resource

          # Inicjalizujemy formularz bez użycia from_model
          @form = form(VotingForm).from_params(
            {
              title: voting.title.is_a?(Hash) ? voting.title : {},
              description: voting.description.is_a?(Hash) ? voting.description : {},
              start_date: voting.start_date,
              end_date: voting.end_date,
              secret: voting.secret
            }
          )
        end

        def update
          enforce_permission_to :update, :voting, voting: resource
          voting = resource # Potrzebujemy obiektu do aktualizacji

          # Przygotuj parametry formularza
          form_params = voting_params
          @form = form(VotingForm).from_params(form_params)

          if @form.valid?
            # Bezpośrednio aktualizujemy atrybuty
            attributes = {
              title: @form.title || {},
              description: @form.description || {},
              start_date: @form.start_date,
              end_date: @form.end_date,
              secret: @form.secret
            }

            if voting.update(attributes)
              flash[:notice] = I18n.t("votings.update.success", scope: "decidim.explicit_voting.admin")
              redirect_to votings_path
            else
              flash.now[:alert] = I18n.t("votings.update.error", scope: "decidim.explicit_voting.admin")
              render :edit, status: :unprocessable_entity
            end
          else
            flash.now[:alert] = I18n.t("votings.update.error", scope: "decidim.explicit_voting.admin")
            render :edit, status: :unprocessable_entity
          end
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
          voting = resource
          
          respond_to do |format|
            format.pdf do
              # Generowanie pliku PDF z wynikami głosowania
              pdf = generate_protocol_pdf(voting)
              
              send_data pdf.render,
                filename: "protokol_glosowania_#{voting.id}.pdf",
                type: "application/pdf",
                disposition: "attachment"
            end
            
            format.html do
              redirect_to votings_path, alert: I18n.t("votings.protocol.no_html_format", scope: "decidim.explicit_voting.admin")
            end
          end
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
        
        def voting_params
          params.require(:voting).permit(
            :start_date, :end_date, :secret,
            title: current_organization.available_locales,
            description: current_organization.available_locales
          )
        end

        # Zwraca kolekcję Voting należących do bieżącego komponentu
        def collection
          @collection ||= Decidim::ExplicitVoting::Voting.where(component: current_component)
        end

        # Zwraca pojedynczy zasób (Voting) na podstawie ID z parametrów
        # Dostępne jako helper_method :resource
        def resource
          @resource ||= collection.find(params[:id])
        end

        # Generuje plik PDF z protokołem głosowania
        def generate_protocol_pdf(voting)
          # Sprawdzamy czy biblioteka Prawn jest dostępna
          unless defined?(Prawn)
            raise "Brak biblioteki Prawn. Upewnij się, że gem prawn jest zainstalowany."
          end
          
          pdf = Prawn::Document.new
          
          # Ustawiamy domyślną czcionkę z obsługą polskich znaków
          set_font(pdf)
          
          # Nagłówek protokołu
          pdf.font_size(16) { pdf.text "Protokół głosowania", align: :center }
          pdf.move_down 10
          pdf.text "ID głosowania: #{voting.id}"
          pdf.text "Pytanie: #{translated_attribute(voting.title)}"
          pdf.text "Data rozpoczęcia: #{I18n.l(voting.start_date, format: :long) if voting.start_date}"
          pdf.text "Data zakończenia: #{I18n.l(voting.end_date, format: :long)}"
          pdf.text "Głosowanie #{voting.secret? ? 'tajne' : 'jawne'}"
          pdf.move_down 20
          
          # Wyniki głosowania
          pdf.font_size(14) { pdf.text "Wyniki głosowania:", style: :bold }
          pdf.move_down 10
          
          options_data = []
          options_data << ["Opcja", "Liczba głosów", "Procent"]
          
          total_votes = voting.votes.count
          
          voting.options.each do |option|
            votes_count = option.votes.count
            percent = total_votes > 0 ? (votes_count.to_f / total_votes * 100).round(2) : 0
            options_data << [translated_attribute(option.name), votes_count.to_s, "#{percent}%"]
          end
          
          pdf.table(options_data, width: pdf.bounds.width) do
            row(0).font_style = :bold
            columns(1..2).align = :center
          end
          
          pdf.move_down 20
          
          # Lista głosujących (tylko dla jawnych głosowań)
          unless voting.secret?
            pdf.font_size(14) { pdf.text "Lista głosujących:", style: :bold }
            pdf.move_down 10
            
            votes_data = []
            votes_data << ["Użytkownik", "Wybrana opcja", "Data oddania głosu"]
            
            voting.votes.includes(:decidim_user, :voting_option).each do |vote|
              user_name = vote.decidim_user&.name || "Nieznany użytkownik"
              option_name = translated_attribute(vote.voting_option&.name) || "Nieznana opcja"
              votes_data << [user_name, option_name, I18n.l(vote.created_at, format: :long)]
            end
            
            pdf.table(votes_data, width: pdf.bounds.width) do
              row(0).font_style = :bold
            end
          end
          
          # Podpis i data wygenerowania protokołu
          pdf.move_down 30
          pdf.text "Protokół wygenerowany: #{I18n.l(Time.current, format: :long)}", align: :right
          
          pdf
        end

        # Generuje plik PDF z listą wszystkich głosowań
        def generate_voting_list_pdf(votings)
          # Sprawdzamy czy biblioteka Prawn jest dostępna
          unless defined?(Prawn)
            raise "Brak biblioteki Prawn. Upewnij się, że gem prawn jest zainstalowany."
          end
          
          pdf = Prawn::Document.new
          
          # Ustawiamy domyślną czcionkę z obsługą polskich znaków
          set_font(pdf)
          
          # Nagłówek
          pdf.font_size(16) { pdf.text "Lista głosowań", align: :center }
          pdf.move_down 20
          
          votings_data = []
          votings_data << ["ID", "Tytuł", "Data rozpoczęcia", "Data zakończenia", "Status", "Tajne", "Liczba głosów"]
          
          votings.each do |voting|
            status = if voting.active?
                      "Aktywne"
                    elsif voting.upcoming?
                      "Nadchodzące"
                    else
                      "Zakończone"
                    end
                    
            votings_data << [
              voting.id.to_s,
              translated_attribute(voting.title).to_s.truncate(30),
              voting.start_date ? I18n.l(voting.start_date, format: :short) : "-",
              I18n.l(voting.end_date, format: :short),
              status,
              voting.secret? ? "Tak" : "Nie",
              voting.votes.count.to_s
            ]
          end
          
          pdf.table(votings_data, width: pdf.bounds.width) do
            row(0).font_style = :bold
            columns(0).align = :center
            columns(2..3).align = :center
            columns(4..6).align = :center
          end
          
          pdf.move_down 20
          pdf.text "Wygenerowano: #{I18n.l(Time.current, format: :long)}", align: :right
          
          pdf
        end
        
        # Ustawia czcionkę z obsługą polskich znaków
        def set_font(pdf)
          # Używamy domyślnej czcionki z fallbackiem na kodowanie ASCII
          pdf.font_families.update(
            "DejaVu" => {
              normal: Rails.root.join("app/assets/fonts/DejaVuSans.ttf").to_s,
              bold: Rails.root.join("app/assets/fonts/DejaVuSans-Bold.ttf").to_s,
              italic: Rails.root.join("app/assets/fonts/DejaVuSans-Oblique.ttf").to_s,
              bold_italic: Rails.root.join("app/assets/fonts/DejaVuSans-BoldOblique.ttf").to_s
            }
          )
          pdf.fallback_fonts(["DejaVu"])
          
          # Ustawiamy czcionkę DejaVu jako domyślną (obsługuje pełne UTF-8)
          pdf.font("DejaVu")
        rescue => e
          # Jeśli nie możemy załadować czcionek, używamy domyślnej czcionki
          Rails.logger.error("Nie można załadować czcionek: #{e.message}")
        end
      end
    end
  end
end