# app/permissions/decidim/explicit_voting/admin/permissions.rb
# frozen_string_literal: true # Dobrą praktyką jest dodanie tej linii

module Decidim
  module ExplicitVoting
    module Admin
      # Wracamy do dziedziczenia z DefaultPermissions
      class Permissions < Decidim::DefaultPermissions
        def permissions
          # Podstawowe warunki - użytkownik zalogowany i scope :admin
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          # Wypiszemy sprawdzaną akcję do logów - pomoże w debugowaniu
          Rails.logger.debug { "DEBUG Permissions: scope=#{permission_action.scope}, subject=#{permission_action.subject.inspect}, action=#{permission_action.action.inspect}, user=#{user&.email}" }

          # === NOWA REGUŁA: Czy admin może czytać przestrzeń? ===
          # Ten test jest często wykonywany jako pierwszy. Logi pokazały, że jest potrzebny.
          if permission_action.subject == :participatory_space && permission_action.action == :read
            Rails.logger.debug { "DEBUG Permissions: Checking :participatory_space :read" }
            # Pozwól, jeśli user jest globalnym adminem LUB adminem przestrzeni
            allow! if user_is_admin? || user_is_space_admin?
            # Zwracamy permission_action niezależnie, czy allow! było wywołane, czy nie.
            # Jeśli allow! nie było, Decidim sam zinterpretuje brak jako odmowę.
            # Można też jawnie zwrócić jeśli allow!, a inaczej pozwolić przejść dalej,
            # ale tutaj założenie jest, że tylko admini mogą czytać przestrzeń w panelu admina.
            return permission_action
          end

          # Obsługa zarządzania komponentem/ustawieniami
          # Ten test prawdopodobnie nastąpi PO przejściu testu :participatory_space :read
          if permission_action.subject == :component && [:manage, :update].include?(permission_action.action)
            Rails.logger.debug { "DEBUG Permissions: Checking :component :manage/:update" }
            # Pozwól, jeśli user jest globalnym adminem LUB adminem przestrzeni
            allow! if user_is_admin? || user_is_space_admin?
            return permission_action # Zakończ sprawdzanie dla tego przypadku
          end

          # Obsługa zasobu :voting (Twoja poprzednia logika)
          if permission_action.subject == :voting
            Rails.logger.debug { "DEBUG Permissions: Checking :voting actions" }
            case permission_action.action
            when :create, :read, :update, :destroy, :manage
              # Użyj toggle_allow lub allow! - allow! jest czytelniejsze, gdy warunek jest prosty
              allow! if user_is_admin? || user_is_space_admin?
            end
            # Zwróć, aby zakończyć przetwarzanie dla tego subjectu
            return permission_action
          end

          # Możesz dodać obsługę innych zasobów (:inny_model, itp.) tutaj
          Rails.logger.debug { "DEBUG Permissions: No specific rule matched for subject=#{permission_action.subject.inspect}" }

          # Zawsze zwracaj obiekt permission_action na końcu
          permission_action
        end

        private

        # Sprawdza, czy użytkownik jest globalnym adminem Decidim
        def user_is_admin?
          user&.admin?
        end

        # Sprawdza, czy użytkownik jest adminem przestrzeni komponentu
        def user_is_space_admin?
          # Użyjmy standardowego sprawdzania roli i pobierzmy przestrzeń z komponentu
          # Ważne: Potrzebujemy komponentu, aby znaleźć przestrzeń!
          current_component = component # Pobierz komponent raz
          return false unless current_component&.participatory_space
          user.role?("admin").for?(current_component.participatory_space)
        end

        # Metoda pomocnicza do pobrania komponentu z kontekstu
        # Potrzebna do user_is_space_admin? oraz potencjalnie do innych reguł
        def component
          # Spróbuj pobrać z różnych kluczy, w których może się znajdować
          context.fetch(:current_component, nil) || context.fetch(:component, nil)
        end
      end
    end
  end
end